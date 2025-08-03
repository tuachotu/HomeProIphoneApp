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