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
    @State private var showingNotesList = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationLink(destination: HomeDetailView(home: home)
            .environmentObject(authManager)) {
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
            print("🏠 HomeCardView appeared for home: \(home.name ?? "Unknown")")
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
            // Home name (primary)
            Text(home.name ?? "My Home")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)

            // Address (if available)
            if let address = home.address, !address.isEmpty {
                Text(address)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(2)
            }

            // Role badge
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
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Items Button
            Button(action: {
                showingItemsList = true
            }) {
                actionButtonContent(icon: "square.grid.3x3", label: "Items", color: DesignSystem.Colors.primary)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingItemsList) {
                HomeItemsListView(home: home)
                    .environmentObject(authManager)
            }

            // Notes Button
            Button(action: {
                showingNotesList = true
            }) {
                actionButtonContent(icon: "note.text", label: "Notes", color: DesignSystem.Colors.accent)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingNotesList) {
                NavigationView {
                    NoteListView(homeId: home.id, homeItemId: nil)
                        .navigationTitle("Home Notes")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }

            Spacer()
        }
    }

    private func actionButtonContent(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))

            Text(label)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
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