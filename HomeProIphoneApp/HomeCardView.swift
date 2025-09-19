//
//  HomeCardView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/9/25.
//

import SwiftUI

struct HomeCardView: View {
    let home: Home
    @State private var photos: [Photo] = []
    @State private var isLoadingPhotos = false
    @State private var showingItemsList = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationLink(destination: HomeDetailView(home: home)) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Home Photo
                homePhotoSection
                
                // Home Info
                homeInfoSection
                
                // Stats Section
                statsSection
            }
            .padding(DesignSystem.Spacing.lg)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            print("🏠 HomeCardView appeared for home: \(home.address ?? "Unknown")")
            loadHomePhotos()
        }
    }
    
    private var homePhotoSection: some View {
        Group {
            if isLoadingPhotos {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.paleGray)
                    .frame(height: 200)
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                    }
            } else if let primaryPhoto = photos.first(where: { $0.isPrimary }) ?? photos.first {
                CachedAsyncImage(url: primaryPhoto.url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(DesignSystem.CornerRadius.md)
                } placeholder: {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.paleGray)
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .font(.system(size: 32))
                        }
                }
            } else {
                // Default placeholder when no photos
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.paleGray)
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            HouseIconView(size: 48, systemName: "house")
                            Text("No photos yet")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
            }
        }
    }
    
    private var homeInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(home.address ?? "Home")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(2)
            
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "person.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                    .font(.caption)
                Text(home.role.capitalized)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
    
    private var statsSection: some View {
        Button(action: {
            showingItemsList = true
        }) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                statItemContent(icon: "square.grid.3x3", value: "\(home.stats.totalItems)", label: "Items", color: DesignSystem.Colors.primary)
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .sheet(isPresented: $showingItemsList) {
            HomeItemsListView(home: home)
                .environmentObject(authManager)
        }
    }
    
    
    private func statItemContent(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(value)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Text(label)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
    }
    
    private func loadHomePhotos() {
        print("📸 Starting to load photos for home: \(home.id)")
        guard !isLoadingPhotos else { 
            print("📸 Already loading photos, skipping...")
            return 
        }
        
        Task {
            await MainActor.run {
                isLoadingPhotos = true
                print("📸 Set loading state to true")
            }
            
            do {
                if let firebaseUser = authManager.user {
                    print("📸 Getting Firebase token for photos...")
                    let firebaseToken = try await firebaseUser.getIDToken()
                    print("📸 Fetching photos from API...")
                    let homePhotos = try await APIService.shared.getPhotos(for: home.id, firebaseToken: firebaseToken)
                    print("📸 Successfully loaded \(homePhotos.count) photos for home")
                    
                    // Log photo details
                    for (index, photo) in homePhotos.enumerated() {
                        print("📷 Photo \(index + 1): \(photo.fileName) - Primary: \(photo.isPrimary)")
                        print("   🔗 URL: \(photo.url)")
                    }
                    
                    await MainActor.run {
                        photos = homePhotos
                        isLoadingPhotos = false
                        print("📸 Photos updated in UI, loading state set to false")
                    }
                } else {
                    print("❌ No Firebase user available for photo loading")
                    await MainActor.run {
                        isLoadingPhotos = false
                    }
                }
            } catch {
                print("❌ Error loading home photos: \(error.localizedDescription)")
                await MainActor.run {
                    isLoadingPhotos = false
                }
            }
        }
    }
}