//
//  UserModel.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import Foundation

struct BackendUser: Codable {
    let id: String
    let name: String
    let roleType: String
    
    var isHomeOwner: Bool {
        return roleType == "HO"
    }
    
    var roleDisplayName: String {
        switch roleType {
        case "HO":
            return "Home Owner"
        default:
            return roleType
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case roleType = "roleType"
    }
}

struct HomeStats: Codable {
    let totalItems: Int
    let totalPhotos: Int
    let emergencyItems: Int
    
    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case totalPhotos = "total_photos"
        case emergencyItems = "emergency_items"
    }
}

struct Home: Codable, Identifiable {
    let id: String
    let address: String?
    let role: String
    let createdAt: String
    let updatedAt: String
    let stats: HomeStats
    
    enum CodingKeys: String, CodingKey {
        case id, address, role, stats
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Photo: Codable, Identifiable {
    let id: String
    let fileName: String
    let caption: String?
    let isPrimary: Bool
    let createdAt: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id, url
        case fileName = "file_name"
        case caption = "caption"
        case isPrimary = "is_primary" 
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        isPrimary = try container.decode(Bool.self, forKey: .isPrimary)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        url = try container.decode(String.self, forKey: .url)
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case unauthorized
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}