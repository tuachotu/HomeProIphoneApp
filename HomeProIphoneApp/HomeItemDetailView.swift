//
//  HomeItemDetailView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/31/25.
//

import SwiftUI

struct HomeItemDetailView: View {
    let homeItem: HomeItem
    let home: Home
    @State private var photos: [Photo] = []
    @State private var currentPhotoIndex = 0
    @State private var isLoadingPhotos = false
    @State private var showingFullScreenPhoto = false
    @State private var showingPhotoUpload = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Photo section
                photoSection
                
                // Item details section
                itemDetailsSection
                
                // Additional data section
                if let dataDict = homeItem.dataDict, !dataDict.isEmpty {
                    additionalDataSection
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .navigationTitle(homeItem.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingPhotoUpload = true
                }) {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .onAppear {
            loadPhotos()
        }
        .fullScreenCover(isPresented: $showingFullScreenPhoto) {
            FullScreenPhotoView(
                photos: photos,
                currentIndex: $currentPhotoIndex
            )
        }
        .sheet(isPresented: $showingPhotoUpload) {
            PhotoUploadView(homeItem: homeItem) {
                // Refresh photos after upload
                loadPhotos()
            }
            .environmentObject(authManager)
        }
    }
    
    private var photoSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if isLoadingPhotos {
                photoLoadingView
            } else if photos.isEmpty {
                photoPlaceholderView
            } else {
                photoCarouselView
            }
        }
    }
    
    private var photoLoadingView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
            .fill(DesignSystem.Colors.paleGray)
            .frame(height: 300)
            .overlay {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                    .scaleEffect(1.5)
            }
    }
    
    private var photoPlaceholderView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
            .fill(DesignSystem.Colors.paleGray)
            .frame(height: 300)
            .overlay {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: homeItem.type.iconName)
                        .font(.system(size: 64))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("No photos yet")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Button(action: {
                        showingPhotoUpload = true
                    }) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "camera.fill")
                            Text("Add Photos")
                        }
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(DesignSystem.Colors.primary)
                        )
                    }
                }
            }
    }
    
    private var photoCarouselView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Main photo display
            Button(action: {
                showingFullScreenPhoto = true
            }) {
                ZStack {
                    CachedAsyncImage(url: photos[currentPhotoIndex].url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(DesignSystem.CornerRadius.md)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.paleGray)
                            .frame(height: 300)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                    .font(.system(size: 32))
                            }
                    }
                    
                    // Full screen indicator
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 32, height: 32)
                                )
                                .padding()
                        }
                        Spacer()
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Navigation controls
            if photos.count > 1 {
                photoNavigationControls
            }
            
            // Photo counter and add more button
            HStack {
                Text("\(currentPhotoIndex + 1) of \(photos.count)")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    showingPhotoUpload = true
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "plus")
                        Text("Add More")
                    }
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(DesignSystem.Colors.primary, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var photoNavigationControls: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Button(action: previousPhoto) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(DesignSystem.Typography.caption)
                .foregroundColor(currentPhotoIndex > 0 ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(currentPhotoIndex > 0 ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary, lineWidth: 1)
                )
            }
            .disabled(currentPhotoIndex <= 0)
            
            Spacer()
            
            Button(action: nextPhoto) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(DesignSystem.Typography.caption)
                .foregroundColor(currentPhotoIndex < photos.count - 1 ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(currentPhotoIndex < photos.count - 1 ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary, lineWidth: 1)
                )
            }
            .disabled(currentPhotoIndex >= photos.count - 1)
        }
    }
    
    private var itemDetailsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Item Details")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                DetailRow(label: "Type", value: homeItem.type.displayName, icon: homeItem.type.iconName)
                DetailRow(label: "Home", value: home.address ?? "Unknown", icon: "house")
                DetailRow(label: "Created", value: formatDate(homeItem.createdAt), icon: "calendar")
                
                if homeItem.isEmergency {
                    DetailRow(label: "Status", value: "Emergency Item", icon: "exclamationmark.triangle.fill", valueColor: DesignSystem.Colors.error)
                }
                
                if homeItem.photoCount > 0 {
                    DetailRow(label: "Photos", value: "\(homeItem.photoCount) photo\(homeItem.photoCount == 1 ? "" : "s")", icon: "photo")
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var additionalDataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Additional Information")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            if let dataDict = homeItem.dataDict {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    ForEach(Array(dataDict.keys.sorted()), id: \.self) { key in
                        if let value = dataDict[key] {
                            DetailRow(
                                label: key.capitalized.replacingOccurrences(of: "_", with: " "),
                                value: "\(value)",
                                icon: "info.circle"
                            )
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func loadPhotos() {
        print("📸 Starting to load photos for home item: \(homeItem.id)")
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
                    print("📸 Getting Firebase token for home item photos...")
                    let firebaseToken = try await firebaseUser.getIDToken()
                    print("📸 Fetching photos from API for home item...")
                    
                    let itemPhotos = try await APIService.shared.getPhotosForHomeItem(
                        homeItemId: homeItem.id,
                        firebaseToken: firebaseToken
                    )
                    
                    print("📸 Successfully loaded \(itemPhotos.count) photos for home item")
                    
                    // Sort photos with primary first, then by creation date
                    let sortedPhotos = itemPhotos.sorted { photo1, photo2 in
                        if photo1.isPrimary && !photo2.isPrimary {
                            return true
                        } else if !photo1.isPrimary && photo2.isPrimary {
                            return false
                        } else {
                            return photo1.createdAt > photo2.createdAt
                        }
                    }
                    
                    // Log photo details
                    for (index, photo) in sortedPhotos.enumerated() {
                        print("📷 Photo \(index + 1): \(photo.fileName) - Primary: \(photo.isPrimary)")
                    }
                    
                    await MainActor.run {
                        photos = sortedPhotos
                        currentPhotoIndex = 0 // Start with first photo (which should be primary)
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
                print("❌ Error loading home item photos: \(error.localizedDescription)")
                await MainActor.run {
                    isLoadingPhotos = false
                }
            }
        }
    }
    
    private func previousPhoto() {
        guard currentPhotoIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPhotoIndex -= 1
        }
    }
    
    private func nextPhoto() {
        guard currentPhotoIndex < photos.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPhotoIndex += 1
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = DesignSystem.Colors.textPrimary
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.Colors.primary)
                .font(.callout)
                .frame(width: 20)
            
            Text(label)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(valueColor)
                .fontWeight(.medium)
        }
    }
}

struct FullScreenPhotoView: View {
    let photos: [Photo]
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Top navigation bar
                topNavigationBar
                
                Spacer()
                
                // Photo display
                photoDisplay
                
                Spacer()
                
                // Bottom navigation
                bottomNavigationBar
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    
                    if value.translation.height > threshold {
                        dismiss()
                    } else if abs(value.translation.width) > threshold && photos.count > 1 {
                        if value.translation.width < 0 && currentIndex < photos.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex += 1
                            }
                        } else if value.translation.width > 0 && currentIndex > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex -= 1
                            }
                        }
                    }
                    
                    withAnimation(.spring()) {
                        dragOffset = .zero
                    }
                }
        )
    }
    
    private var topNavigationBar: some View {
        HStack {
            Button("Close") {
                dismiss()
            }
            .font(DesignSystem.Typography.body)
            .foregroundColor(.white)
            .padding()
            
            Spacer()
            
            Text("\(currentIndex + 1) of \(photos.count)")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.white)
                .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var photoDisplay: some View {
        CachedAsyncImage(url: photos[currentIndex].url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(dragOffset)
        } placeholder: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
        }
        .clipped()
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = max(1.0, min(3.0, value))
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        scale = 1.0
                    }
                }
        )
    }
    
    private var bottomNavigationBar: some View {
        HStack {
            Button(action: {
                guard currentIndex > 0 else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentIndex -= 1
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(DesignSystem.Typography.callout)
                .foregroundColor(currentIndex > 0 ? .white : .gray)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(Color.black.opacity(0.6))
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(currentIndex <= 0)
            
            Spacer()
            
            Text(photos[currentIndex].fileName)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                guard currentIndex < photos.count - 1 else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentIndex += 1
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(DesignSystem.Typography.callout)
                .foregroundColor(currentIndex < photos.count - 1 ? .white : .gray)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(Color.black.opacity(0.6))
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(currentIndex >= photos.count - 1)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    NavigationView {
        HomeItemDetailView(
            homeItem: HomeItem(
                id: "preview-item-id",
                name: "Kitchen Refrigerator",
                type: .appliance,
                isEmergency: false,
                data: ["brand": "Samsung", "model": "RF28T5001SG"],
                createdAt: "2025-08-01T10:00:00",
                photoCount: 3,
                primaryPhotoUrl: nil
            ),
            home: Home(
                id: "preview-home-id",
                address: "123 Main Street",
                role: "owner",
                createdAt: "2025-08-01T10:00:00",
                updatedAt: "2025-08-01T10:00:00",
                stats: HomeStats(totalItems: 5, totalPhotos: 12, emergencyItems: 2)
            )
        )
    }
    .environmentObject(AuthenticationManager())
}