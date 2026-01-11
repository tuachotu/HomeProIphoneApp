//
//  PhotoUploadView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/31/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct PhotoUploadView: View {
    let homeItem: HomeItem
    let onPhotosUploaded: () -> Void

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isUploading = false
    @State private var uploadProgress: [Int: Double] = [:]
    @State private var uploadedCount = 0
    @State private var failedCount = 0
    @State private var totalCount = 0
    @State private var errorMessage: String?
    @State private var showingSuccess = false
    @State private var uploadErrors: [String] = []
    @State private var showingCamera = false
    @State private var showingCameraPermission = false
    @State private var showingPhotoSourcePicker = false

    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    private let maxPhotos = 10
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header section
                headerSection
                
                if selectedImages.isEmpty {
                    // Photo picker section
                    photoPickerSection
                } else {
                    // Selected photos preview
                    selectedPhotosSection
                    
                    // Upload section
                    if !isUploading {
                        uploadButtonSection
                    } else {
                        uploadProgressSection
                    }
                }
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .navigationTitle("Upload Photos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isUploading)
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Upload Complete", isPresented: $showingSuccess) {
                Button("Done") {
                    onPhotosUploaded()
                    dismiss()
                }
                if failedCount > 0 {
                    Button("View Errors") {
                        errorMessage = "Upload Summary:\n✅ \(uploadedCount) successful\n❌ \(failedCount) failed\n\nError details:\n\(uploadErrors.joined(separator: "\n"))"
                    }
                }
            } message: {
                if failedCount > 0 {
                    Text("\(uploadedCount) photo\(uploadedCount == 1 ? "" : "s") uploaded successfully!\n\(failedCount) photo\(failedCount == 1 ? "" : "s") failed.")
                } else {
                    Text("\(uploadedCount) photo\(uploadedCount == 1 ? "" : "s") uploaded successfully!")
                }
            }
        }
        .onChange(of: selectedPhotos) { _ in
            loadSelectedImages()
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(isPresented: $showingCamera, onImageCaptured: { capturedImage in
                addCapturedImage(capturedImage)
            }, onError: { error in
                errorMessage = error
            })
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingCameraPermission) {
            CameraPermissionView(isPresented: $showingCameraPermission)
        }
        .confirmationDialog("Add Photos", isPresented: $showingPhotoSourcePicker) {
            Button("Take Photo") {
                openCamera()
            }
            Button("Choose from Library") {
                // This will be handled by PhotosPicker
                showingPhotoSourcePicker = false
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: homeItem.type.iconName)
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Uploading photos to:")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(homeItem.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var photoPickerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Upload illustration
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 64))
                    .foregroundColor(DesignSystem.Colors.textTertiary)

                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Add Photos")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("Take new photos or choose up to \(maxPhotos) from your library")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Camera button
            Button(action: openCamera) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "camera.fill")
                    Text("Take Photo")
                }
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.primary)
                )
            }
            .disabled(isUploading)

            // Divider with "or" text
            HStack(spacing: DesignSystem.Spacing.md) {
                Rectangle()
                    .fill(DesignSystem.Colors.border)
                    .frame(height: 1)

                Text("or")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)

                Rectangle()
                    .fill(DesignSystem.Colors.border)
                    .frame(height: 1)
            }

            // Photo library picker button
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: maxPhotos,
                matching: .images
            ) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "photo.badge.plus")
                    Text("Choose from Library")
                }
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(Color.clear)
                        .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                )
            }
            .disabled(isUploading)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var selectedPhotosSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Selected Photos (\(selectedImages.count))")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                if !isUploading && selectedImages.count < maxPhotos {
                    Button(action: openCamera) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "camera.fill")
                            Text("Add More")
                        }
                    }
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primary)
                }

                if !isUploading {
                    Button("Clear") {
                        selectedPhotos.removeAll()
                        selectedImages.removeAll()
                    }
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.error)
                }
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
                ], spacing: DesignSystem.Spacing.sm) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(DesignSystem.CornerRadius.sm)
                            
                            // Upload progress overlay
                            if isUploading {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 100, height: 100)
                                    .overlay {
                                        if let progress = uploadProgress[index] {
                                            if progress >= 1.0 {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.green)
                                            } else {
                                                VStack(spacing: DesignSystem.Spacing.xs) {
                                                    ProgressView(value: progress)
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                        .scaleEffect(0.8)
                                                    
                                                    Text("\(Int(progress * 100))%")
                                                        .font(DesignSystem.Typography.caption2)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        } else {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .cardStyle()
    }
    
    private var uploadButtonSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button(action: uploadPhotos) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "icloud.and.arrow.up")
                    Text("Upload \(selectedImages.count) Photo\(selectedImages.count == 1 ? "" : "s")")
                }
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.primary)
                )
            }
            .disabled(selectedImages.isEmpty)
            
            Text("Photos will be uploaded to the server and associated with this home item.")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var uploadProgressSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Uploading Photos...")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ProgressView(value: Double(uploadedCount), total: Double(totalCount))
                    .progressViewStyle(LinearProgressViewStyle(tint: DesignSystem.Colors.primary))
                
                Text("\(uploadedCount + failedCount) of \(totalCount) photos processed (✅\(uploadedCount) ❌\(failedCount))")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Processing and uploading photos...")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                
                Text("Images are automatically resized and compressed for optimal upload.")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func loadSelectedImages() {
        selectedImages.removeAll()
        
        Task {
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImages.append(uiImage)
                    }
                }
            }
        }
    }
    
    private func uploadPhotos() {
        guard !selectedImages.isEmpty,
              let firebaseUser = authManager.user else {
            errorMessage = "Authentication required"
            return
        }
        
        isUploading = true
        uploadedCount = 0
        failedCount = 0
        totalCount = selectedImages.count
        uploadProgress.removeAll()
        uploadErrors.removeAll()
        errorMessage = nil
        
        Task {
            do {
                print("🔐 Getting Firebase token for photo upload...")
                let firebaseToken = try await firebaseUser.getIDToken()
                
                print("📸 Starting upload of \(selectedImages.count) photos to item: \(homeItem.id)")
                
                // Upload photos concurrently but with some throttling
                await withTaskGroup(of: Void.self) { group in
                    for (index, image) in selectedImages.enumerated() {
                        group.addTask {
                            await uploadSinglePhoto(
                                image: image,
                                index: index,
                                firebaseToken: firebaseToken
                            )
                        }
                        
                        // Small delay to avoid overwhelming the server
                        if index % 3 == 2 {
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        }
                    }
                }
                
                await MainActor.run {
                    print("🔄 Upload process completed. Success: \(uploadedCount), Failed: \(failedCount)")
                    isUploading = false
                    
                    if uploadedCount > 0 {
                        showingSuccess = true
                    } else if failedCount > 0 {
                        // All uploads failed
                        errorMessage = "All photo uploads failed. Error details:\n\(uploadErrors.joined(separator: "\n"))"
                    } else {
                        // This shouldn't happen, but just in case
                        errorMessage = "No photos were processed. Please try again."
                    }
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Error getting Firebase token: \(error)")
                    errorMessage = "Authentication failed: \(error.localizedDescription)"
                    isUploading = false
                }
            }
        }
    }
    
    private func uploadSinglePhoto(image: UIImage, index: Int, firebaseToken: String) async {
        do {
            // Update progress to show starting
            await MainActor.run {
                uploadProgress[index] = 0.1
            }
            
            // Resize and compress image to ensure it's under size limits
            let processedImageData = try await processImageForUpload(image)
            
            print("📸 Image processed for photo \(index + 1):")
            print("   📐 Original size: ~\(estimateImageSize(image)) bytes")
            print("   📦 Compressed size: \(processedImageData.count) bytes (\(String(format: "%.2f", Double(processedImageData.count) / (1024.0 * 1024.0))) MB)")
            print("   📊 Compression ratio: \(String(format: "%.1f", (Double(estimateImageSize(image)) / Double(processedImageData.count))))x")
            
            // Validate size before upload
            let maxAllowedSize = 500 * 1024 // 500KB
            if processedImageData.count > maxAllowedSize {
                print("⚠️ WARNING: Processed image is still \(processedImageData.count) bytes, which exceeds \(maxAllowedSize) bytes!")
            } else {
                print("✅ Image size is acceptable: \(processedImageData.count) bytes (\(String(format: "%.1f", Double(processedImageData.count) / 1024.0)) KB)")
            }
            
            await MainActor.run {
                uploadProgress[index] = 0.3
            }
            
            // Generate filename
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "photo_\(timestamp)_\(index).jpg"
            
            print("📸 Uploading photo \(index + 1): \(filename) (\(processedImageData.count) bytes)")
            
            await MainActor.run {
                uploadProgress[index] = 0.5
            }
            
            // Upload to API
            print("📸 About to call API for photo \(index + 1)")
            print("   🏠 Home item ID: \(homeItem.id)")
            print("   📁 Filename: \(filename)")
            print("   📦 Data size: \(processedImageData.count) bytes")
            
            let response = try await APIService.shared.uploadPhotoForHomeItem(
                homeItemId: homeItem.id,
                imageData: processedImageData,
                fileName: filename,
                firebaseToken: firebaseToken
            )
            
            print("📸 API call completed for photo \(index + 1), got response: \(response)")
            
            await MainActor.run {
                uploadProgress[index] = 1.0
                uploadedCount += 1
                print("✅ Successfully uploaded photo \(index + 1): \(response.fileName)")
            }
            
        } catch {
            await MainActor.run {
                uploadProgress[index] = 0.0
                failedCount += 1
                let errorDetails = "Photo \(index + 1): \(error.localizedDescription)"
                uploadErrors.append(errorDetails)
                print("❌ Error uploading photo \(index + 1): \(error)")
                print("   📄 Detailed error: \(errorDetails)")
                
                // Continue with other photos but track the failure
            }
        }
    }
    
    // MARK: - Image Processing Methods
    
    private func processImageForUpload(_ image: UIImage) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let processedData = try self.resizeAndCompressImage(image)
                    continuation.resume(returning: processedData)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func resizeAndCompressImage(_ image: UIImage) throws -> Data {
        // Define size limits - very conservative to avoid server rejection
        let maxFileSize = 500 * 1024 // 500KB max file size
        let maxDimension: CGFloat = 800 // Max width or height
        
        // Step 1: Resize if image is too large
        var processedImage = image
        let currentSize = image.size
        
        if currentSize.width > maxDimension || currentSize.height > maxDimension {
            let scaleFactor = min(maxDimension / currentSize.width, maxDimension / currentSize.height)
            let newSize = CGSize(width: currentSize.width * scaleFactor, height: currentSize.height * scaleFactor)
            
            print("📐 Resizing image from \(currentSize) to \(newSize) (scale: \(String(format: "%.2f", scaleFactor)))")
            
            // Resize the image
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            processedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        // Step 2: Compress with different quality levels until under size limit
        let qualityLevels: [CGFloat] = [0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.15, 0.1, 0.05]
        
        for quality in qualityLevels {
            guard let compressedData = processedImage.jpegData(compressionQuality: quality) else {
                continue
            }
            
            print("🔧 Trying compression quality \(quality): \(compressedData.count) bytes")
            
            if compressedData.count <= maxFileSize {
                print("✅ Image compressed successfully at quality \(quality)")
                return compressedData
            }
        }
        
        // If still too large, try more aggressive resizing
        let smallerDimension: CGFloat = 400 // Very small for size optimization
        let scaleFactor = min(smallerDimension / processedImage.size.width, smallerDimension / processedImage.size.height)
        let smallerSize = CGSize(width: processedImage.size.width * scaleFactor, height: processedImage.size.height * scaleFactor)
        
        print("📐 Aggressive resizing to \(smallerSize)")
        
        UIGraphicsBeginImageContextWithOptions(smallerSize, false, 1.0)
        processedImage.draw(in: CGRect(origin: .zero, size: smallerSize))
        let smallerImage = UIGraphicsGetImageFromCurrentImageContext() ?? processedImage
        UIGraphicsEndImageContext()
        
        // Try compression again with smaller image
        for quality in qualityLevels {
            guard let compressedData = smallerImage.jpegData(compressionQuality: quality) else {
                continue
            }
            
            if compressedData.count <= maxFileSize {
                print("✅ Image compressed successfully after aggressive resizing at quality \(quality)")
                return compressedData
            }
        }
        
        // Last resort: very low quality
        guard let finalData = smallerImage.jpegData(compressionQuality: 0.1) else {
            throw PhotoUploadError.compressionFailed
        }
        
        print("⚠️ Using very low quality compression: \(finalData.count) bytes")
        return finalData
    }
    
    private func estimateImageSize(_ image: UIImage) -> Int {
        // Rough estimate: width * height * 4 bytes per pixel (RGBA)
        return Int(image.size.width * image.size.height * 4)
    }

    // MARK: - Camera Functions

    private func openCamera() {
        print("📸 openCamera() called")

        // First check if camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌ Camera source type not available (probably simulator)")
            errorMessage = "Camera is not available on this device. Camera only works on physical devices, not the simulator."
            return
        }

        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("📸 Camera authorization status: \(cameraStatus.rawValue)")

        switch cameraStatus {
        case .authorized:
            print("✅ Camera already authorized, opening camera")
            showingCamera = true

        case .notDetermined:
            print("📸 Camera permission not determined, requesting access")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    print("📸 Camera permission request result: \(granted)")
                    if granted {
                        self.showingCamera = true
                    } else {
                        self.showingCameraPermission = true
                    }
                }
            }

        case .denied:
            print("⚠️ Camera permission denied, showing permission view")
            showingCameraPermission = true

        case .restricted:
            print("⚠️ Camera access restricted")
            showingCameraPermission = true

        @unknown default:
            print("❌ Unknown camera permission status")
            showingCameraPermission = true
        }
    }

    private func addCapturedImage(_ image: UIImage) {
        print("📸 addCapturedImage() called with image size: \(image.size)")

        guard selectedImages.count < maxPhotos else {
            print("⚠️ Maximum photos (\(maxPhotos)) already selected")
            errorMessage = "Maximum of \(maxPhotos) photos allowed"
            return
        }

        selectedImages.append(image)
        print("✅ Added captured photo. Total photos: \(selectedImages.count)")
    }
}

enum PhotoUploadError: Error, LocalizedError {
    case compressionFailed
    case imageTooLarge
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .imageTooLarge:
            return "Image is too large even after compression"
        }
    }
}

#Preview {
    PhotoUploadView(
        homeItem: HomeItem(
            id: "preview-item-id",
            name: "Kitchen Refrigerator",
            type: .appliance,
            isEmergency: false,
            data: nil,
            createdAt: "2025-08-01T10:00:00",
            photoCount: 0,
            noteCount: 0,
            primaryPhotoUrl: nil
        ),
        onPhotosUploaded: {}
    )
    .environmentObject(AuthenticationManager())
}