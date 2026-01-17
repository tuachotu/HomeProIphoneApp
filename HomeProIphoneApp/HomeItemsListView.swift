//
//  HomeItemsListView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/31/25.
//

import SwiftUI

enum ItemFilter: Hashable {
    case all
    case emergency
    case type(HomeItemType)

    var displayName: String {
        switch self {
        case .all:
            return "All Items"
        case .emergency:
            return "Emergency"
        case .type(let itemType):
            return itemType.displayName
        }
    }
}

struct HomeItemsListView: View {
    let home: Home
    @State private var homeItems: [HomeItem] = []
    @State private var isLoadingItems = false
    @State private var errorMessage: String?
    @State private var selectedFilter: ItemFilter = .all
    @State private var showingAddItem = false
    @State private var selectedItem: HomeItem?
    @State private var showingItemDetail = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Filter section
            if !isLoadingItems && !homeItems.isEmpty {
                filterSection
                Divider()
            }

            // Content
            if isLoadingItems {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if homeItems.isEmpty {
                emptyStateView
            } else {
                itemsScrollView
            }
        }
        .navigationTitle("Items")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadHomeItems()
        }
        .sheet(isPresented: $showingAddItem) {
            AddHomeItemView(home: home) { newItem in
                loadHomeItems()
            }
            .environmentObject(authManager)
        }
        .sheet(isPresented: $showingItemDetail, onDismiss: {
            loadHomeItems()
        }) {
            if let selectedItem = selectedItem {
                NavigationView {
                    HomeItemDetailView(homeItem: selectedItem, home: home)
                        .environmentObject(authManager)
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Items")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()

            Button(action: { showingAddItem = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Add Item")
                }
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    private var filterSection: some View {
        HStack {
            Text("Filter:")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Picker("Filter", selection: $selectedFilter) {
                Text(ItemFilter.all.displayName).tag(ItemFilter.all)
                Text(ItemFilter.emergency.displayName).tag(ItemFilter.emergency)

                ForEach(HomeItemType.allCases, id: \.self) { type in
                    Text(ItemFilter.type(type).displayName).tag(ItemFilter.type(type))
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedFilter) { _, _ in
                loadHomeItems()
            }

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading items...")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(DesignSystem.Colors.error)

            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                loadHomeItems()
            }
            .secondaryButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text(selectedFilter != .all ? "No items found" : "No items yet")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Text(selectedFilter != .all
                 ? "Try adjusting your filters"
                 : "Add your first item to get started")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)

            if selectedFilter == .all {
                Button("Add Item") {
                    showingAddItem = true
                }
                .primaryButtonStyle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var itemsScrollView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Emergency items section
                if emergencyItems.count > 0 {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("EMERGENCY")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.horizontal, DesignSystem.Spacing.md)

                        ForEach(emergencyItems) { item in
                            ItemCardView(item: item, onTap: {
                                selectedItem = item
                                showingItemDetail = true
                            })
                        }
                    }
                }

                // Regular items section
                if regularItems.count > 0 {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        if emergencyItems.count > 0 {
                            Text("ITEMS")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                        }

                        ForEach(regularItems) { item in
                            ItemCardView(item: item, onTap: {
                                selectedItem = item
                                showingItemDetail = true
                            })
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .refreshable {
            await refreshItems()
        }
    }

    private var emergencyItems: [HomeItem] {
        homeItems.filter { $0.isEmergency }
    }

    private var regularItems: [HomeItem] {
        homeItems.filter { !$0.isEmergency }
    }

    private func loadHomeItems() {
        guard !isLoadingItems else { return }

        Task {
            await MainActor.run {
                isLoadingItems = true
                errorMessage = nil
            }

            do {
                if let firebaseUser = authManager.user {
                    let firebaseToken = try await firebaseUser.getIDToken()

                    // Convert selectedFilter to API parameters
                    var filterType: HomeItemType? = nil
                    var emergency: Bool? = nil

                    switch selectedFilter {
                    case .all:
                        filterType = nil
                        emergency = nil
                    case .emergency:
                        filterType = nil
                        emergency = true
                    case .type(let itemType):
                        filterType = itemType
                        emergency = nil
                    }

                    let items = try await APIService.shared.getHomeItems(
                        for: home.id,
                        firebaseToken: firebaseToken,
                        type: filterType,
                        emergency: emergency
                    )

                    await MainActor.run {
                        homeItems = items
                        isLoadingItems = false
                    }
                } else {
                    await MainActor.run {
                        isLoadingItems = false
                        errorMessage = "Authentication required"
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingItems = false
                    errorMessage = "Failed to load items: \(error.localizedDescription)"
                }
            }
        }
    }

    private func refreshItems() async {
        await MainActor.run {
            isLoadingItems = false
        }
        loadHomeItems()
    }
}

struct ItemCardView: View {
    let item: HomeItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Item type icon with emergency indicator
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: item.type.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 40, height: 40)
                        .background(DesignSystem.Colors.primaryLight)
                        .cornerRadius(DesignSystem.CornerRadius.sm)

                    if item.isEmergency {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }

                // Item info
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(item.type.displayName)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)

                    // Photo and Note counts
                    HStack(spacing: DesignSystem.Spacing.md) {
                        if item.photoCount > 0 {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "photo")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                Text("\(item.photoCount)")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }

                        if item.noteCount > 0 {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "note.text")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                Text("\(item.noteCount)")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }
                }

                Spacer()

                // Primary photo preview
                if let photoUrl = item.primaryPhotoUrl {
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
        HomeItemsListView(home: Home(
            id: "preview-home-id",
            name: "My Family Home",
            address: "123 Main Street",
            role: "owner",
            createdAt: "2025-08-01T10:00:00",
            updatedAt: "2025-08-01T10:00:00",
            stats: HomeStats(totalItems: 5, totalPhotos: 12, emergencyItems: 2)
        ))
        .environmentObject(AuthenticationManager())
    }
}
