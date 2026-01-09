//
//  HomeDetailView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/12/25.
//

import SwiftUI

struct HomeDetailView: View {
    let home: Home
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var homeItems: [HomeItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAddItem = false
    @State private var selectedItem: HomeItem?
    @State private var showingItemPhotos = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    @State private var showingAllItems = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Home Header
                homeHeaderSection
                
                // Home Items Section
                homeItemsSection
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("Home Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.error)
                }
                .disabled(isDeleting)
            }
        }
        .onAppear {
            loadHomeItems()
        }
        .refreshable {
            await refreshHomeItems()
        }
        .sheet(isPresented: $showingAddItem) {
            AddHomeItemView(home: home) { newItem in
                homeItems.append(newItem)
                showingAddItem = false
            }
        }
        .sheet(isPresented: $showingItemPhotos) {
            if let selectedItem = selectedItem {
                ItemPhotosView(homeItem: selectedItem)
            }
        }
        .sheet(isPresented: $showingAllItems, onDismiss: {
            // Refresh items when returning from full items view
            loadHomeItems()
        }) {
            HomeItemsListView(home: home)
                .environmentObject(authManager)
        }
        .alert("Delete Home", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteHome()
            }
        } message: {
            Text("Are you sure you want to delete this home and all its items? This will permanently delete \(home.stats.totalItems) item\(home.stats.totalItems == 1 ? "" : "s") and \(home.stats.totalPhotos) photo\(home.stats.totalPhotos == 1 ? "" : "s"). This action cannot be undone.")
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { deleteError != nil },
            set: { if !$0 { deleteError = nil } }
        )) {
            Button("OK") { }
        } message: {
            Text(deleteError ?? "")
        }
        .overlay {
            if isDeleting {
                deletingOverlay
            }
        }
        .sequentialTapDeveloperGesture()
    }
    
    private var homeHeaderSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Home Icon
            HouseIconView(size: 48, systemName: "house.fill")
            
            // Home Information
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(home.address ?? "Home")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.caption)
                    Text(home.role.capitalized)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            // Statistics
            HStack(spacing: DesignSystem.Spacing.lg) {
                StatCardView(
                    title: "Items",
                    value: "\(home.stats.totalItems)",
                    icon: "cube.box",
                    color: DesignSystem.Colors.primary
                )
                
                StatCardView(
                    title: "Photos",
                    value: "\(home.stats.totalPhotos)",
                    icon: "photo",
                    color: DesignSystem.Colors.secondary
                )
                
                StatCardView(
                    title: "Emergency",
                    value: "\(home.stats.emergencyItems)",
                    icon: "exclamationmark.triangle",
                    color: DesignSystem.Colors.error
                )
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var homeItemsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Recent Items")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    if !homeItems.isEmpty && homeItems.count > 3 {
                        Text("Showing \(min(3, homeItems.count)) of \(homeItems.count)")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }

                Spacer()

                if !homeItems.isEmpty && homeItems.count > 3 {
                    Button {
                        showingAllItems = true
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text("View All")
                            Image(systemName: "arrow.right")
                        }
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            // Items Content
            if isLoading {
                loadingSection
            } else if homeItems.isEmpty {
                emptyStateSection
            } else {
                itemsListSection
            }
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading home items...")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .cardStyle()
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "cube.box")
                    .font(.system(size: 48))
                    .foregroundColor(DesignSystem.Colors.textTertiary)

                Text("No Items Yet")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Start organizing your home by adding your first item. Track appliances, utilities, rooms, and more.")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .padding(DesignSystem.Spacing.xl)
            .cardStyle()

            Button {
                showingAddItem = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Item")
                }
                .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
    }
    
    private var itemsListSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Show only first 3 items as preview
            ForEach(Array(homeItems.prefix(3))) { item in
                HomeItemCardView(homeItem: item) {
                    selectedItem = item
                    showingItemPhotos = true
                }
            }

            // Add Item button
            Button {
                showingAddItem = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Item")
                }
                .frame(maxWidth: .infinity)
            }
            .secondaryButtonStyle()
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.sm)
        }
    }
    
    private func loadHomeItems() {
        guard let firebaseUser = authManager.user else {
            errorMessage = "Authentication required"
            isLoading = false
            return
        }
        
        Task {
            do {
                print("🏠 Loading items for home: \(home.id)")
                let firebaseToken = try await firebaseUser.getIDToken()
                let items = try await APIService.shared.getHomeItems(
                    for: home.id,
                    firebaseToken: firebaseToken
                )
                
                await MainActor.run {
                    self.homeItems = items
                    self.isLoading = false
                    print("✅ Loaded \(items.count) home items")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ Failed to load home items: \(error)")
                }
            }
        }
    }
    
    @MainActor
    private func refreshHomeItems() async {
        guard let firebaseUser = authManager.user else { return }

        do {
            let firebaseToken = try await firebaseUser.getIDToken()
            let items = try await APIService.shared.getHomeItems(
                for: home.id,
                firebaseToken: firebaseToken
            )
            homeItems = items
            print("🔄 Refreshed \(items.count) home items")
        } catch {
            print("❌ Failed to refresh home items: \(error)")
        }
    }

    private var deletingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text("Deleting home...")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.white)
            }
            .padding(DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }

    private func deleteHome() {
        guard let firebaseUser = authManager.user else {
            deleteError = "Authentication required"
            return
        }

        isDeleting = true
        deleteError = nil

        Task {
            do {
                print("🔐 Getting Firebase token for home deletion...")
                let firebaseToken = try await firebaseUser.getIDToken()

                print("🗑️ DELETE HOME DEBUG INFO:")
                print("   🏠 Home ID: \(home.id)")
                print("   🏠 Home Address: \(home.address ?? "N/A")")
                print("   📦 Total Items: \(home.stats.totalItems)")
                print("   📷 Total Photos: \(home.stats.totalPhotos)")

                try await APIService.shared.deleteHome(
                    homeId: home.id,
                    firebaseToken: firebaseToken
                )

                print("✅ Successfully deleted home")

                await MainActor.run {
                    isDeleting = false

                    // Refresh homes list in the auth manager
                    Task {
                        await authManager.refreshHomes()
                    }

                    // Dismiss the detail view to go back to the list
                    dismiss()
                }

            } catch {
                await MainActor.run {
                    print("❌ Error deleting home: \(error)")
                    isDeleting = false

                    if let apiError = error as? APIError {
                        switch apiError {
                        case .unauthorized:
                            deleteError = "Authentication failed. Please try logging in again."
                        case .forbidden:
                            deleteError = "You don't have permission to delete this home."
                        case .networkError(let message):
                            deleteError = message
                        case .serverError(let code):
                            deleteError = "Server error (\(code)). Please try again later."
                        default:
                            deleteError = apiError.localizedDescription
                        }
                    } else {
                        deleteError = "Failed to delete home: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}

struct HomeItemCardView: View {
    let homeItem: HomeItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Item Type Icon
                VStack {
                    Image(systemName: homeItem.type.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 40, height: 40)
                        .background(DesignSystem.Colors.primaryLight)
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                    
                    if homeItem.isEmergency {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }
                
                // Item Information
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(homeItem.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(homeItem.type.displayName)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    if homeItem.photoCount > 0 {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text("\(homeItem.photoCount) photo\(homeItem.photoCount == 1 ? "" : "s")")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                }
                
                Spacer()
                
                // Primary Photo Preview
                if let photoUrl = homeItem.primaryPhotoUrl {
                    CachedAsyncImage(url: photoUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(DesignSystem.Colors.background)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                    .font(.system(size: 20))
                            )
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(DesignSystem.Spacing.lg)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        HomeDetailView(
            home: Home(
                id: "1",
                address: "123 Main Street, Portland OR",
                role: "owner",
                createdAt: "2025-08-01T10:00:00",
                updatedAt: "2025-08-07T15:30:00",
                stats: HomeStats(totalItems: 15, totalPhotos: 32, emergencyItems: 3)
            )
        )
        .environmentObject(AuthenticationManager())
    }
}