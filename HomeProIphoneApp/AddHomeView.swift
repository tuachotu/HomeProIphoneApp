//
//  AddHomeView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/31/25.
//

import SwiftUI

struct AddHomeView: View {
    let onHomeAdded: () -> Void
    
    @State private var address: String = ""
    @State private var selectedRole: String = "owner"
    @State private var isCreatingHome = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false
    
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    private let roles = [
        ("owner", "Owner"),
        ("tenant", "Tenant"),
        ("manager", "Property Manager")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header section
                headerSection
                
                // Form section
                formSection
                
                // Create button
                if !isCreatingHome {
                    createButtonSection
                } else {
                    creatingSection
                }
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .navigationTitle("Add New Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCreatingHome)
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Success!", isPresented: $showingSuccess) {
                Button("Done") {
                    onHomeAdded()
                    dismiss()
                }
            } message: {
                Text("Your new home has been added successfully!")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "house.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.primary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Add Your Home")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Enter your home's address and select your role to get started with home management.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Address field
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Home Address")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                TextField("Enter your home address", text: $address)
                    .inputFieldStyle()
                    .disabled(isCreatingHome)
                
                Text("Enter the complete address including street, city, state, and zip code.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            // Role selection
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Your Role")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(roles, id: \.0) { role in
                        Button(action: {
                            selectedRole = role.0
                        }) {
                            HStack {
                                Image(systemName: selectedRole == role.0 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedRole == role.0 ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                                
                                Text(role.1)
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Spacer()
                            }
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .fill(selectedRole == role.0 ? DesignSystem.Colors.primary.opacity(0.1) : Color.clear)
                                    .stroke(selectedRole == role.0 ? DesignSystem.Colors.primary : DesignSystem.Colors.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isCreatingHome)
                    }
                }
                
                Text("Select your relationship to this property.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var createButtonSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button(action: createHome) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Home")
                }
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.primary)
                )
            }
            .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            
            Text("This will create a new home in your account that you can start managing immediately.")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var creatingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Creating Home...")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                    .scaleEffect(1.2)
                
                Text("Setting up your new home...")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Text("Please wait while we create your home profile.")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func createHome() {
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedAddress.isEmpty else {
            errorMessage = "Please enter a valid address"
            return
        }
        
        guard let firebaseUser = authManager.user else {
            errorMessage = "Authentication required"
            return
        }
        
        isCreatingHome = true
        errorMessage = nil
        
        Task {
            do {
                print("🔐 Getting Firebase token for home creation...")
                let firebaseToken = try await firebaseUser.getIDToken()
                
                print("🏠 Creating new home with address: \(trimmedAddress) and role: \(selectedRole)")
                
                let response = try await APIService.shared.createHome(
                    address: trimmedAddress,
                    role: selectedRole,
                    firebaseToken: firebaseToken
                )
                
                print("✅ Successfully created home: \(response)")
                
                await MainActor.run {
                    isCreatingHome = false
                    showingSuccess = true
                    
                    // Refresh homes list in the auth manager
                    Task {
                        await authManager.refreshHomes()
                    }
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Error creating home: \(error)")
                    isCreatingHome = false
                    
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .badRequest:
                            errorMessage = "Invalid home information. Please check your input."
                        case .unauthorized:
                            errorMessage = "Authentication failed. Please try logging in again."
                        case .forbidden:
                            errorMessage = "You don't have permission to create homes."
                        case .serverError(let code):
                            errorMessage = "Server error (\(code)). Please try again later."
                        default:
                            errorMessage = apiError.localizedDescription
                        }
                    } else {
                        errorMessage = "Failed to create home: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    AddHomeView(onHomeAdded: {})
        .environmentObject(AuthenticationManager())
}