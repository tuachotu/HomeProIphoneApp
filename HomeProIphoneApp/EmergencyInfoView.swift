//
//  EmergencyInfoView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import SwiftUI

struct EmergencyInfoView: View {
    let home: Home
    let selectedTab: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var emergencyInfo: EmergencyInfo?
    @State private var isLoading = true
    @State private var showingAddInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header Section
                    headerSection
                    
                    // Emergency Information Content
                    if isLoading {
                        loadingSection
                    } else if let info = emergencyInfo, info.hasAnyInformation {
                        emergencyDetailsSection(info: info)
                    } else {
                        emptyStateSection
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Emergency Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        print("🚨 Emergency Info dismissed - returning to tab \(selectedTab)")
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🚨 EmergencyInfoView appeared for home: \(home.address ?? home.id)")
            loadEmergencyInfo()
        }
        .sheet(isPresented: $showingAddInfo) {
            AddEmergencyInfoView(home: home) { newInfo in
                emergencyInfo = newInfo
                showingAddInfo = false
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Emergency Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.error)
            
            // Home Address
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Emergency Information")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(home.address ?? "Home")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var loadingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading emergency information...")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .cardStyle()
    }
    
    private func emergencyDetailsSection(info: EmergencyInfo) -> some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Gas Shutoff
            if let gasLocation = info.gasShutoffLocation {
                emergencyDetailCard(
                    icon: "flame.fill",
                    title: "Gas Shutoff Valve",
                    description: gasLocation,
                    color: .orange
                )
            }
            
            // Water Shutoff
            if let waterLocation = info.waterShutoffLocation {
                emergencyDetailCard(
                    icon: "drop.fill",
                    title: "Water Shutoff Valve",
                    description: waterLocation,
                    color: .blue
                )
            }
            
            // Electrical Main
            if let electricalLocation = info.electricalMainLocation {
                emergencyDetailCard(
                    icon: "bolt.fill",
                    title: "Main Electrical Switch",
                    description: electricalLocation,
                    color: .yellow
                )
            }
            
            // Additional Notes
            if let notes = info.additionalNotes, !notes.isEmpty {
                emergencyDetailCard(
                    icon: "note.text",
                    title: "Additional Notes",
                    description: notes,
                    color: DesignSystem.Colors.primary
                )
            }
            
            // Edit Button
            Button {
                showingAddInfo = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Emergency Information")
                }
                .frame(maxWidth: .infinity)
            }
            .secondaryButtonStyle()
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Empty State Illustration
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text("No Emergency Information")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Add important emergency details like shutoff valve locations to keep your home safe.")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .padding(DesignSystem.Spacing.xl)
            .cardStyle()
            
            // Add Information Button
            Button {
                print("🚨 User tapped Add Emergency Information")
                showingAddInfo = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Emergency Information")
                }
                .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
        }
    }
    
    private func emergencyDetailCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(description)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private func loadEmergencyInfo() {
        // Simulate API call - in real implementation, this would call the backend
        print("🚨 Loading emergency information for home: \(home.id)")
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // For now, we'll simulate no emergency info exists
            // In a real implementation, this would make an API call
            emergencyInfo = nil
            isLoading = false
            print("🚨 Emergency info loading completed - no info found")
        }
    }
}

// Placeholder for Add/Edit Emergency Info View
struct AddEmergencyInfoView: View {
    let home: Home
    let onSave: (EmergencyInfo) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Emergency Information")
                    .font(DesignSystem.Typography.title1)
                    .padding()
                
                Text("This feature is coming soon!")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
            }
            .navigationTitle("Add Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EmergencyInfoView(
        home: Home(
            id: "1",
            address: "123 Main Street, Portland OR",
            role: "owner",
            createdAt: "",
            updatedAt: "",
            stats: HomeStats(totalItems: 0, totalPhotos: 0, emergencyItems: 0)
        ),
        selectedTab: 0
    )
}