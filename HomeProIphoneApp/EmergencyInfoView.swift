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
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var emergencyItems: [HomeItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedItem: HomeItem?
    @State private var showingItemDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection

                // Content
                if isLoading {
                    loadingView
                } else if emergencyItems.isEmpty {
                    emptyStateView
                } else {
                    emergencyItemsListView
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Emergency Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        print("🚨 Emergency Items dismissed - returning to tab \(selectedTab)")
                        dismiss()
                    }
                }
            }
            .environmentObject(authManager)  // Add here for all child views
        }
        .environmentObject(authManager)  // Add here for NavigationView
        .onAppear {
            print("🚨 EmergencyInfoView appeared - loading emergency items from all homes")
            loadEmergencyItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("🚨 EmergencyInfoView: App became active - checking for stuck states")
            // Reset stuck loading state
            if isLoading {
                print("🚨 EmergencyInfoView: Resetting stuck loading state")
                isLoading = false
            }
            // Reload data if we have no items but should have them
            if emergencyItems.isEmpty && !isLoading {
                print("🚨 EmergencyInfoView: Reloading emergency items after app activation")
                loadEmergencyItems()
            }
        }
        .sheet(isPresented: $showingItemDetail) {
            if let selectedItem = selectedItem {
                let _ = print("🚨 Sheet presenting for item: \(selectedItem.name)")
                let _ = print("🚨 authManager in sheet: \(authManager)")
                NavigationView {
                    HomeItemDetailView(homeItem: selectedItem, home: findHomeForItem(selectedItem))
                        .environmentObject(authManager)  // Add here too
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back") {
                                    print("🚨 Back button tapped in item detail")
                                    showingItemDetail = false
                                }
                            }
                        }
                        .onAppear {
                            print("🚨 HomeItemDetailView appeared")
                        }
                }
                .environmentObject(authManager)  // Add here
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(authManager)  // And here for good measure
            } else {
                let _ = print("🚨 Sheet trying to present but selectedItem is nil")
                EmptyView()
                    .environmentObject(authManager)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Critical items across all your homes")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.background)
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                .scaleEffect(1.5)

            Text("Loading emergency items...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Emergency Items")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("You don't have any items marked as emergency items yet. Add items to your homes and mark them as emergency to see them here.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }

    private var emergencyItemsListView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(emergencyItems) { item in
                    Button(action: {
                        print("🚨 Emergency item tapped: \(item.name)")
                        print("🚨 authManager available: \(authManager)")
                        print("🚨 About to set selectedItem and showingItemDetail")
                        selectedItem = item
                        showingItemDetail = true
                        print("🚨 selectedItem set to: \(selectedItem?.name ?? "nil")")
                        print("🚨 showingItemDetail set to: \(showingItemDetail)")
                    }) {
                        EmergencyItemRowView(item: item, homes: authManager.homes)
                            .environmentObject(authManager)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .refreshable {
            print("🚨 Pull-to-refresh triggered")
            loadEmergencyItems()
        }
    }

    private func findHomeForItem(_ item: HomeItem) -> Home {
        // Since we're loading items from all homes, we need to find which home this item belongs to
        // For now, return the default home passed in, but in a real implementation we'd track this
        return home
    }

    private func loadEmergencyItems() {
        print("🚨 ===== EMERGENCY ITEMS LOAD STARTED =====")
        print("🚨 authManager: \(authManager)")
        print("🚨 authManager.homes: \(authManager.homes)")
        print("🚨 authManager.homes.count: \(authManager.homes.count)")
        print("🚨 Current isLoading state: \(isLoading)")

        // FIXED: Reset loading state first, then check
        if isLoading {
            print("🚨 ⚠️ isLoading was true, resetting it to false first")
            isLoading = false
        }

        // Now proceed without the guard that was blocking us
        print("🚨 ✅ Proceeding with load (isLoading now: \(isLoading))")

        // If no homes, just load first home for now (same as working version loads single home)
        guard let firstHome = authManager.homes.first else {
            print("❌ ===== NO HOMES AVAILABLE - THIS IS THE PROBLEM =====")
            print("❌ authManager.homes is empty: \(authManager.homes)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "No homes found"
            }
            return
        }

        print("🚨 ✅ Found first home: \(firstHome.address ?? firstHome.id)")
        print("🚨 ✅ Home ID: \(firstHome.id)")
        print("🚨 ✅ About to start Task...")

        Task {
            print("🚨 ✅ Task started!")

            await MainActor.run {
                isLoading = true
                errorMessage = nil
                print("🚨 ✅ Set loading state to true on MainActor")
            }

            print("🚨 ✅ Starting do block...")
            do {
                print("🚨 ✅ Checking authManager.user...")
                print("🚨 authManager.user: \(authManager.user?.email ?? "nil")")

                if let firebaseUser = authManager.user {
                    print("🚨 ✅ Firebase user found: \(firebaseUser.email ?? "no email")")
                    print("🚨 ✅ Getting Firebase token...")

                    let firebaseToken = try await firebaseUser.getIDToken()
                    print("🚨 ✅ Got Firebase token (length: \(firebaseToken.count))")
                    print("🚨 ✅ About to call API for home: \(firstHome.id)")

                    // EXACT same API call as working HomeItemsListView - including emergency filter
                    let items = try await APIService.shared.getHomeItems(
                        for: firstHome.id,
                        firebaseToken: firebaseToken,
                        type: nil,
                        emergency: true  // Filter on server side like the working version
                    )

                    print("🚨 ✅ API CALL COMPLETED! Got \(items.count) emergency items")

                    // Log item details (same as working version)
                    for (index, item) in items.enumerated() {
                        print("📋 Emergency Item \(index + 1): \(item.name) (\(item.type.displayName)) - Emergency: \(item.isEmergency) - Photos: \(item.photoCount)")
                    }

                    print("🚨 ✅ About to update UI on MainActor...")
                    await MainActor.run {
                        emergencyItems = items
                        isLoading = false
                        print("🚨 ✅ FINAL SUCCESS: Emergency items updated in UI, loading state set to false")
                        print("🚨 ✅ emergencyItems.count = \(emergencyItems.count)")
                    }
                } else {
                    print("❌ NO FIREBASE USER - this is likely the issue")
                    print("❌ authManager.user is nil")
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Authentication required"
                        print("❌ Set isLoading = false due to no user")
                    }
                }
            } catch {
                print("❌ CATCH BLOCK: Error loading emergency items: \(error)")
                print("❌ Error type: \(type(of: error))")
                print("❌ Error description: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    print("❌ Set isLoading = false due to error")
                }
            }
        }
    }
}

struct EmergencyItemRowView: View {
    let item: HomeItem
    let homes: [Home]

    private var homeAddress: String {
        // Find the home this item belongs to
        // For now, we'll show "Unknown Home" since we don't track home ownership per item
        // In a full implementation, you'd either include home info in the HomeItem model
        // or track it separately
        return "From: Unknown Home"
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Emergency indicator
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundColor(DesignSystem.Colors.error)
                .frame(width: 32, height: 32)

            // Item info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(item.name)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(2)

                Text(item.type.displayName)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)

                Text(homeAddress)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)

                // Additional info row
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if item.photoCount > 0 {
                        Label("\(item.photoCount)", systemImage: "photo")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }

                    if let dataDict = item.dataDict,
                       let location = dataDict["location"] as? String {
                        Text("• \(location)")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }

            Spacer()

            // Primary photo or placeholder
            Group {
                if let primaryPhotoUrl = item.primaryPhotoUrl {
                    CachedAsyncImage(url: primaryPhotoUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(DesignSystem.Colors.paleGray)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                    .font(.title3)
                            }
                    }
                } else {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.paleGray)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: item.type.iconName)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .font(.title3)
                        }
                }
            }

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.error.opacity(0.1))
                .stroke(DesignSystem.Colors.error.opacity(0.3), lineWidth: 1)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
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
    .environmentObject(AuthenticationManager())
}