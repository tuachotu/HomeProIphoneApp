//
//  ImageCacheManager.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import Foundation
import SwiftUI
import CommonCrypto

class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Create cache directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("ImageCache")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Configure cache
        cache.countLimit = 100 // Max 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        print("🗄️ ImageCacheManager initialized with cache directory: \(cacheDirectory.path)")
    }
    
    func cachedImage(for url: String) -> UIImage? {
        let cacheKey = NSString(string: url.md5)
        
        // Check memory cache first
        if let data = cache.object(forKey: cacheKey) {
            print("💾 Image found in memory cache for: \(url)")
            return UIImage(data: data as Data)
        }
        
        // Check disk cache
        let filePath = cacheDirectory.appendingPathComponent(cacheKey as String)
        if let data = try? Data(contentsOf: filePath) {
            print("💿 Image found in disk cache for: \(url)")
            // Store in memory cache for faster access
            cache.setObject(data as NSData, forKey: cacheKey)
            return UIImage(data: data)
        }
        
        print("❌ Image not found in cache for: \(url)")
        return nil
    }
    
    func downloadAndCacheImage(from url: String) async throws -> UIImage {
        print("⬇️ Starting download for image: \(url)")
        
        guard let imageURL = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            throw ImageCacheError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: imageURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Failed to download image, status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            throw ImageCacheError.downloadFailed
        }
        
        guard let image = UIImage(data: data) else {
            print("❌ Failed to create image from downloaded data")
            throw ImageCacheError.invalidImageData
        }
        
        print("✅ Successfully downloaded image (\(data.count) bytes)")
        
        // Cache the image
        await cacheImage(data: data, for: url)
        
        return image
    }
    
    private func cacheImage(data: Data, for url: String) async {
        let cacheKey = NSString(string: url.md5)
        
        // Store in memory cache
        cache.setObject(data as NSData, forKey: cacheKey)
        print("💾 Stored image in memory cache for: \(url)")
        
        // Store in disk cache
        let filePath = cacheDirectory.appendingPathComponent(cacheKey as String)
        do {
            try data.write(to: filePath)
            print("💿 Stored image in disk cache for: \(url)")
        } catch {
            print("❌ Failed to store image in disk cache: \(error)")
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            print("🗑️ Cache cleared successfully")
        } catch {
            print("❌ Failed to clear cache: \(error)")
        }
    }
    
    func getCacheSize() -> String {
        var totalSize: Int64 = 0
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            for file in files {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                if let size = attributes[.size] as? Int64 {
                    totalSize += size
                }
            }
        } catch {
            print("❌ Failed to calculate cache size: \(error)")
        }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
}

enum ImageCacheError: Error, LocalizedError {
    case invalidURL
    case downloadFailed
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .downloadFailed:
            return "Failed to download image"
        case .invalidImageData:
            return "Invalid image data"
        }
    }
}

// Extension to create MD5 hash for cache keys
extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

