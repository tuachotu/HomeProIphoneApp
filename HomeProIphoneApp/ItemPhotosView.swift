//
//  ItemPhotosView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/12/25.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct ItemPhotosView: View {
    let homeItem: HomeItem
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var photos: [Photo] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploading = false
    @State private var selectedPhotoIndex: Int?
    @State private var showingFullScreenPhoto = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Item Header
                    itemHeaderSection
                    
                    // Photos Section
                    photosSection
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Item Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPhotoPicker = true
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Photo")
                        }
                        .font(DesignSystem.Typography.callout)
                    }
                    .disabled(isUploading)
                }
            }
        }
        .onAppear {
            loadPhotos()
        }
        .refreshable {
            await refreshPhotos()
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhoto) { newItem in
            if let newItem = newItem {
                uploadPhoto(from: newItem)
            }
        }
        .fullScreenCover(isPresented: $showingFullScreenPhoto) {
            if let index = selectedPhotoIndex {
                PhotoViewerView(photos: photos, initialIndex: index)
            }
        }
    }
    
    private var itemHeaderSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Item Icon
            Image(systemName: homeItem.type.iconName)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.primary)
            
            // Item Information
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(homeItem.name)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(homeItem.type.displayName)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    if homeItem.isEmergency {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }
            }
            
            // Photo Count
            if !photos.isEmpty {
                Text("\(photos.count) photo\(photos.count == 1 ? "" : "s")")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Section Header
            HStack {
                Text("Photos")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if isUploading {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Uploading...")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            // Photos Content
            if isLoading {
                loadingSection
            } else if photos.isEmpty {
                emptyStateSection
            } else {
                photosGridSection
            }
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading photos...")
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
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 48))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text("No Photos Yet")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Add photos to document this item. Photos help with maintenance, warranty claims, and reference.")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .padding(DesignSystem.Spacing.xl)
            .cardStyle()
            
            Button {
                showingPhotoPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Photo")
                }
                .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .disabled(isUploading)
        }
    }
    
    private var photosGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
        ], spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                PhotoThumbnailView(photo: photo, isPrimary: photo.isPrimary) {
                    selectedPhotoIndex = index
                    showingFullScreenPhoto = true
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private func loadPhotos() {
        guard let firebaseUser = authManager.user else {
            errorMessage = "Authentication required"
            isLoading = false
            return
        }
        
        Task {
            do {
                print("📸 Loading photos for item: \(homeItem.id)")
                let firebaseToken = try await firebaseUser.getIDToken()
                let itemPhotos = try await APIService.shared.getPhotosForHomeItem(
                    homeItemId: homeItem.id,
                    firebaseToken: firebaseToken
                )
                
                await MainActor.run {
                    self.photos = itemPhotos
                    self.isLoading = false
                    print("✅ Loaded \(itemPhotos.count) photos for item")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ Failed to load photos: \(error)")
                }
            }
        }
    }
    
    @MainActor
    private func refreshPhotos() async {
        guard let firebaseUser = authManager.user else { return }
        
        do {
            let firebaseToken = try await firebaseUser.getIDToken()
            let itemPhotos = try await APIService.shared.getPhotosForHomeItem(
                homeItemId: homeItem.id,
                firebaseToken: firebaseToken
            )
            photos = itemPhotos
            print("🔄 Refreshed \(itemPhotos.count) photos for item")
        } catch {
            print("❌ Failed to refresh photos: \(error)")
        }
    }
    
    private func uploadPhoto(from item: PhotosPickerItem) {
        guard let firebaseUser = authManager.user else {
            errorMessage = "Authentication required"
            return
        }
        
        isUploading = true
        selectedPhoto = nil
        
        Task {
            do {
                guard let imageData = try await item.loadTransferable(type: Data.self) else {
                    throw APIError.noData
                }
                
                // Generate a filename
                let filename = "IMG_\(Date().timeIntervalSince1970).jpg"
                
                print("📸 Uploading photo for item: \(homeItem.id)")
                let firebaseToken = try await firebaseUser.getIDToken()
                let uploadResponse = try await APIService.shared.uploadPhotoForHomeItem(
                    homeItemId: homeItem.id,
                    imageData: imageData,
                    fileName: filename,
                    firebaseToken: firebaseToken
                )
                
                // Create Photo object from upload response - need to use decoder since Photo doesn't have custom init
                let photoData = """
                {
                    "id": "\(uploadResponse.id)",
                    "file_name": "\(uploadResponse.fileName)",
                    "caption": \(uploadResponse.caption.map { "\"\($0)\"" } ?? "null"),
                    "is_primary": \(photos.isEmpty),
                    "created_at": "\(ISO8601DateFormatter().string(from: Date()))",
                    "url": "\(uploadResponse.photoUrl ?? "")"
                }
                """.data(using: .utf8)!
                
                let newPhoto = try JSONDecoder().decode(Photo.self, from: photoData)
                
                await MainActor.run {
                    self.photos.append(newPhoto)
                    self.isUploading = false
                    print("✅ Successfully uploaded photo: \(uploadResponse.id)")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isUploading = false
                    print("❌ Failed to upload photo: \(error)")
                }
            }
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: Photo
    let isPrimary: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                CachedAsyncImage(url: photo.url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(DesignSystem.CornerRadius.md)
                } placeholder: {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.background)
                        .frame(width: 100, height: 100)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                
                if isPrimary {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(DesignSystem.Colors.primary)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PhotoViewerView: View {
    let photos: [Photo]
    let initialIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    
    init(photos: [Photo], initialIndex: Int) {
        self.photos = photos
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    CachedAsyncImage(url: photo.url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                if photos.count > 1 {
                    Text("\(currentIndex + 1) of \(photos.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        ItemPhotosView(
            homeItem: HomeItem(
                id: "1",
                name: "Kitchen Refrigerator",
                type: .appliance,
                isEmergency: false,
                data: nil,
                createdAt: "2025-08-12T10:00:00",
                photoCount: 3,
                primaryPhotoUrl: nil
            )
        )
        .environmentObject(AuthenticationManager())
    }
}