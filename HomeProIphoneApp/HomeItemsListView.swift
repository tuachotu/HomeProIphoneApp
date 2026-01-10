//
//  HomeItemsListView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/31/25.
//

import SwiftUI

struct HomeItemsListView: View {
    let home: Home
    @State private var homeItems: [HomeItem] = []
    @State private var isLoadingItems = false
    @State private var errorMessage: String?
    @State private var filterType: HomeItemType?
    @State private var showingEmergencyOnly = false
    @State private var showingAddItem = false
    @State private var selectedItem: HomeItem?
    @State private var showingItemDetail = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Debug info at the top
                if let _ = errorMessage {
                    // Error will be shown in emptyStateView
                } else {
                    // Show debug info
                    Text("Home ID: \(home.id)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                // Filter section
                filterSection
                
                // Content with floating button overlay
                ZStack(alignment: .bottomTrailing) {
                    // Main content
                    if isLoadingItems {
                        loadingView
                    } else if homeItems.isEmpty {
                        emptyStateView
                    } else {
                        itemsListView
                    }
                    
                    // Floating Action Button - positioned to not interfere with list
                    Button(action: {
                        showingAddItem = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Home Items")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadHomeItems()
            }
            .sheet(isPresented: $showingAddItem) {
                AddHomeItemView(home: home) { newItem in
                    // Refresh items list when new item is added
                    loadHomeItems()
                }
                .environmentObject(authManager)
            }
            .sheet(isPresented: $showingItemDetail, onDismiss: {
                // Refresh items list when detail view is dismissed (e.g., after deletion)
                loadHomeItems()
            }) {
                if let selectedItem = selectedItem {
                    NavigationView {
                        HomeItemDetailView(homeItem: selectedItem, home: home)
                            .environmentObject(authManager)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Back") {
                                        showingItemDetail = false
                                    }
                                }
                            }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var filterSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Filters")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // All items filter
                    FilterChip(
                        title: "All",
                        isSelected: filterType == nil && !showingEmergencyOnly,
                        action: {
                            filterType = nil
                            showingEmergencyOnly = false
                            loadHomeItems()
                        }
                    )
                    
                    // Emergency filter
                    FilterChip(
                        title: "Emergency",
                        isSelected: showingEmergencyOnly,
                        action: {
                            filterType = nil
                            showingEmergencyOnly = true
                            loadHomeItems()
                        }
                    )
                    
                    // Type filters
                    ForEach(HomeItemType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.displayName,
                            isSelected: filterType == type && !showingEmergencyOnly,
                            action: {
                                filterType = type
                                showingEmergencyOnly = false
                                loadHomeItems()
                            }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.background)
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                .scaleEffect(1.5)
            
            Text("Loading home items...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Items Found")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if filterType != nil || showingEmergencyOnly {
                    Text("Try adjusting your filters to see more items.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("This home doesn't have any items yet.")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Add items using the + button, then tap items to upload photos.")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(homeItems) { item in
                    Button(action: {
                        print("🔍 Row tapped for item: \(item.name)")
                        selectedItem = item
                        showingItemDetail = true
                    }) {
                        HomeItemRowView(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                }
                
                // Bottom spacer to prevent floating button overlap
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 80)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .refreshable {
            await refreshItems()
        }
    }
    
    private func loadHomeItems() {
        print("🏠 ========================================")
        print("🏠 LOAD HOME ITEMS DEBUG")
        print("🏠 Home ID: \(home.id)")
        print("🏠 Home Address: \(home.address ?? "N/A")")
        print("🏠 User Role: \(home.role)")
        print("🏠 ========================================")

        guard !isLoadingItems else {
            print("🏠 Already loading home items, skipping...")
            return
        }

        Task {
            await MainActor.run {
                isLoadingItems = true
                errorMessage = nil
                print("🏠 Set loading state to true")
            }
            
            do {
                if let firebaseUser = authManager.user {
                    print("🏠 Getting Firebase token for home items...")
                    let firebaseToken = try await firebaseUser.getIDToken()
                    print("🏠 Fetching home items from API...")
                    
                    let items = try await APIService.shared.getHomeItems(
                        for: home.id,
                        firebaseToken: firebaseToken,
                        type: filterType,
                        emergency: showingEmergencyOnly ? true : nil
                    )
                    
                    print("🏠 Successfully loaded \(items.count) home items")

                    // Log item details with IDs
                    for (index, item) in items.enumerated() {
                        print("📋 Item \(index + 1):")
                        print("   Name: \(item.name)")
                        print("   ID: \(item.id)")
                        print("   Type: \(item.type.displayName)")
                        print("   Emergency: \(item.isEmergency)")
                        print("   Photos: \(item.photoCount)")
                    }
                    
                    await MainActor.run {
                        homeItems = items
                        isLoadingItems = false
                        print("🏠 Home items updated in UI, loading state set to false")
                    }
                } else {
                    print("❌ No Firebase user available for home items loading")
                    await MainActor.run {
                        isLoadingItems = false
                        errorMessage = "Authentication required"
                    }
                }
            } catch {
                print("❌ Error loading home items: \(error.localizedDescription)")
                await MainActor.run {
                    isLoadingItems = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func refreshItems() async {
        print("🔄 Refreshing home items...")
        await MainActor.run {
            isLoadingItems = false
        }
        loadHomeItems()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.offWhite)
                        .stroke(DesignSystem.Colors.primary, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HomeItemRowView: View {
    let item: HomeItem
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Item type icon
            Image(systemName: item.type.iconName)
                .font(.title2)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 32, height: 32)
            
            // Item info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(item.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                    
                    if item.isEmergency {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }
                
                Text(item.type.displayName)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                // Additional info row
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if item.photoCount > 0 {
                        Label("\(item.photoCount)", systemImage: "photo")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    
                    if let dataDict = item.dataDict,
                       let brand = dataDict["brand"] as? String {
                        Text("• \(brand)")
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
                .fill(Color.blue.opacity(0.1))
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    HomeItemsListView(home: Home(
        id: "preview-home-id",
        address: "123 Main Street",
        role: "owner",
        createdAt: "2025-08-01T10:00:00",
        updatedAt: "2025-08-01T10:00:00",
        stats: HomeStats(totalItems: 5, totalPhotos: 12, emergencyItems: 2)
    ))
    .environmentObject(AuthenticationManager())
}