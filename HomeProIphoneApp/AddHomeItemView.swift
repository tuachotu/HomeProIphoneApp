//
//  AddHomeItemView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/12/25.
//

import SwiftUI

struct AddHomeItemView: View {
    let home: Home
    let onItemCreated: (HomeItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var itemName = ""
    @State private var selectedType = HomeItemType.appliance
    @State private var isEmergency = false
    @State private var itemData = ItemDataForm()
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Form Header
                    headerSection
                    
                    // Item Details Form
                    formSection
                    
                    // Item Data Form
                    itemDataSection
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createItem()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: selectedType.iconName)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.primary)
            
            // Home Info
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Adding Item to")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text(home.address ?? "Home")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var formSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Item Details")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                // Item Name
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Item Name")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    TextField("e.g., Kitchen Refrigerator", text: $itemName)
                        .inputFieldStyle()
                }
                
                // Item Type Picker
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Item Type")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Picker("Item Type", selection: $selectedType) {
                        ForEach(HomeItemType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(DesignSystem.Colors.primary)
                }
                
                // Emergency Toggle
                Toggle(isOn: $isEmergency) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Emergency Item")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text("Mark this item for emergency access")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var itemDataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Additional Information")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ItemDataFormView(itemType: selectedType, itemData: $itemData)
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private func createItem() {
        guard let firebaseUser = authManager.user else {
            errorMessage = "Authentication required"
            return
        }
        
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Item name is required"
            return
        }
        
        isCreating = true
        errorMessage = nil
        
        Task {
            do {
                print("🏠 Creating item: \(trimmedName) for home: \(home.id)")
                
                let firebaseToken = try await firebaseUser.getIDToken()
                let dataJson = itemData.isEmpty ? nil : itemData.toJsonString()
                
                let response = try await APIService.shared.createHomeItem(
                    for: home.id,
                    name: trimmedName,
                    itemType: selectedType,
                    isEmergency: isEmergency,
                    data: dataJson,
                    firebaseToken: firebaseToken
                )
                
                // Create HomeItem from response
                let homeItem = HomeItem(
                    id: response.id,
                    name: response.name,
                    type: response.type,
                    isEmergency: response.isEmergency,
                    data: nil,
                    createdAt: response.createdAt,
                    photoCount: 0,
                    noteCount: 0,
                    primaryPhotoUrl: nil
                )
                
                await MainActor.run {
                    print("✅ Successfully created item: \(response.id)")
                    onItemCreated(homeItem)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isCreating = false
                    print("❌ Failed to create item: \(error)")
                }
            }
        }
    }
}

struct ItemDataForm {
    var brand = ""
    var model = ""
    var purchaseDate = ""
    var warranty = ""
    var location = ""
    var size = ""
    var installationDate = ""
    var notes = ""
    
    var isEmpty: Bool {
        brand.isEmpty && model.isEmpty && purchaseDate.isEmpty && 
        warranty.isEmpty && location.isEmpty && size.isEmpty && 
        installationDate.isEmpty && notes.isEmpty
    }
    
    func toJsonString() -> String? {
        var data: [String: String] = [:]
        
        if !brand.isEmpty { data["brand"] = brand }
        if !model.isEmpty { data["model"] = model }
        if !purchaseDate.isEmpty { data["purchaseDate"] = purchaseDate }
        if !warranty.isEmpty { data["warranty"] = warranty }
        if !location.isEmpty { data["location"] = location }
        if !size.isEmpty { data["size"] = size }
        if !installationDate.isEmpty { data["installationDate"] = installationDate }
        if !notes.isEmpty { data["notes"] = notes }
        
        guard !data.isEmpty else { return nil }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("❌ Failed to serialize item data: \(error)")
            return nil
        }
    }
}

struct ItemDataFormView: View {
    let itemType: HomeItemType
    @Binding var itemData: ItemDataForm
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            switch itemType {
            case .appliance:
                applianceFields
            case .utilityControl:
                utilityControlFields
            case .room:
                roomFields
            case .structural:
                structuralFields
            case .wiring:
                wiringFields
            case .sensor:
                sensorFields
            case .observation:
                observationFields
            case .other:
                genericFields
            }
        }
    }
    
    private var applianceFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Brand", text: $itemData.brand, placeholder: "e.g., Samsung")
            FormFieldView(title: "Model", text: $itemData.model, placeholder: "e.g., RF28T5001SG")
            FormFieldView(title: "Purchase Date", text: $itemData.purchaseDate, placeholder: "e.g., 2023-01-15")
            FormFieldView(title: "Warranty", text: $itemData.warranty, placeholder: "e.g., 2 years")
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Kitchen")
        }
    }
    
    private var utilityControlFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Under kitchen sink")
            FormFieldView(title: "Brand", text: $itemData.brand, placeholder: "e.g., Kohler")
            FormFieldView(title: "Model", text: $itemData.model, placeholder: "e.g., K-1234")
            FormFieldView(title: "Size", text: $itemData.size, placeholder: "e.g., 1 inch")
            FormFieldView(title: "Installation Date", text: $itemData.installationDate, placeholder: "e.g., 2023-05-15")
        }
    }
    
    private var roomFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Size", text: $itemData.size, placeholder: "e.g., 200 sq ft")
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Second floor")
            FormFieldView(title: "Notes", text: $itemData.notes, placeholder: "Additional details...")
        }
    }
    
    private var structuralFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Basement")
            FormFieldView(title: "Size", text: $itemData.size, placeholder: "e.g., 8x12 beam")
            FormFieldView(title: "Installation Date", text: $itemData.installationDate, placeholder: "e.g., 2020-03-15")
            FormFieldView(title: "Notes", text: $itemData.notes, placeholder: "Additional details...")
        }
    }
    
    private var wiringFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Living room wall")
            FormFieldView(title: "Brand", text: $itemData.brand, placeholder: "e.g., Leviton")
            FormFieldView(title: "Model", text: $itemData.model, placeholder: "e.g., 5621-W")
            FormFieldView(title: "Installation Date", text: $itemData.installationDate, placeholder: "e.g., 2022-08-10")
        }
    }
    
    private var sensorFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Brand", text: $itemData.brand, placeholder: "e.g., Nest")
            FormFieldView(title: "Model", text: $itemData.model, placeholder: "e.g., Protect 2nd Gen")
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Hallway ceiling")
            FormFieldView(title: "Installation Date", text: $itemData.installationDate, placeholder: "e.g., 2023-06-20")
        }
    }
    
    private var observationFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "e.g., Basement wall")
            FormFieldView(title: "Notes", text: $itemData.notes, placeholder: "Describe your observation...")
        }
    }
    
    private var genericFields: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FormFieldView(title: "Brand", text: $itemData.brand, placeholder: "Brand name")
            FormFieldView(title: "Model", text: $itemData.model, placeholder: "Model number")
            FormFieldView(title: "Location", text: $itemData.location, placeholder: "Where is it located?")
            FormFieldView(title: "Notes", text: $itemData.notes, placeholder: "Additional details...")
        }
    }
}

struct FormFieldView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            TextField(placeholder, text: $text)
                .inputFieldStyle()
        }
    }
}

#Preview {
    AddHomeItemView(
        home: Home(
            id: "1",
            name: "My Family Home",
            address: "123 Main Street, Portland OR",
            role: "owner",
            createdAt: "2025-08-01T10:00:00",
            updatedAt: "2025-08-07T15:30:00",
            stats: HomeStats(totalItems: 15, totalPhotos: 32, emergencyItems: 3)
        )
    ) { _ in }
    .environmentObject(AuthenticationManager())
}