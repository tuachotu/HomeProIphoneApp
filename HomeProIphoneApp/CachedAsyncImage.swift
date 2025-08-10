//
//  CachedAsyncImage.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: String
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @StateObject private var imageCache = ImageCacheManager.shared
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var hasError = false
    
    init(url: String,
         @ViewBuilder content: @escaping (Image) -> Content,
         @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else if isLoading {
                placeholder()
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                            .scaleEffect(0.8)
                    )
            } else if hasError {
                placeholder()
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(DesignSystem.Colors.error)
                            Text("Failed to load")
                                .font(.caption2)
                                .foregroundColor(DesignSystem.Colors.error)
                        }
                    )
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { _ in
            loadImage()
        }
    }
    
    private func loadImage() {
        print("🖼️ CachedAsyncImage loading image for URL: \(url)")
        
        // Reset state
        hasError = false
        uiImage = nil
        
        // Check cache first
        if let cachedImage = imageCache.cachedImage(for: url) {
            print("⚡ Image loaded from cache")
            self.uiImage = cachedImage
            return
        }
        
        // Download image
        isLoading = true
        
        Task {
            do {
                print("⬇️ Starting image download...")
                let downloadedImage = try await imageCache.downloadAndCacheImage(from: url)
                
                await MainActor.run {
                    print("✅ Image download completed and cached")
                    self.uiImage = downloadedImage
                    self.isLoading = false
                }
            } catch {
                print("❌ Image download failed: \(error.localizedDescription)")
                await MainActor.run {
                    self.hasError = true
                    self.isLoading = false
                }
            }
        }
    }
}

// Convenience initializer similar to AsyncImage
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: String) {
        self.init(url: url) { image in
            image
        } placeholder: {
            Color.gray.opacity(0.3)
        }
    }
}

// Preview provider for SwiftUI previews
struct CachedAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CachedAsyncImage(url: "https://picsum.photos/200/200") { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipped()
                    .cornerRadius(10)
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.system(size: 32))
                    }
            }
            
            Text("Cached AsyncImage Demo")
                .font(.headline)
        }
        .padding()
    }
}