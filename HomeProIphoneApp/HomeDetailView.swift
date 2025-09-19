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
                Text("Home Items")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Button {
                    showingAddItem = true
                } label: {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primary)
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
        VStack(spacing: DesignSystem.Spacing.lg) {
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
        }
    }
    
    private var itemsListSection: some View {
        LazyVStack(spacing: DesignSystem.Spacing.md) {
            ForEach(homeItems) { item in
                HomeItemCardView(homeItem: item) {
                    selectedItem = item
                    showingItemPhotos = true
                }
            }
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