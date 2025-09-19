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

struct EmergencyInfo: Codable, Identifiable {
    let id: String
    let homeId: String
    let gasShutoffLocation: String?
    let waterShutoffLocation: String?
    let electricalMainLocation: String?
    let additionalNotes: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, additionalNotes
        case homeId = "home_id"
        case gasShutoffLocation = "gas_shutoff_location"
        case waterShutoffLocation = "water_shutoff_location"
        case electricalMainLocation = "electrical_main_location"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var hasAnyInformation: Bool {
        return gasShutoffLocation != nil || 
               waterShutoffLocation != nil || 
               electricalMainLocation != nil ||
               (additionalNotes?.isEmpty == false)
    }
}

enum HomeItemType: String, CaseIterable, Codable {
    case room = "room"
    case utilityControl = "utility_control"
    case appliance = "appliance"
    case structural = "structural"
    case observation = "observation"
    case wiring = "wiring"
    case sensor = "sensor"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .room:
            return "Room"
        case .utilityControl:
            return "Utility Control"
        case .appliance:
            return "Appliance"
        case .structural:
            return "Structural"
        case .observation:
            return "Observation"
        case .wiring:
            return "Wiring"
        case .sensor:
            return "Sensor"
        case .other:
            return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .room:
            return "door.left.hand.open"
        case .utilityControl:
            return "dial.min"
        case .appliance:
            return "washer"
        case .structural:
            return "building.columns"
        case .observation:
            return "eye"
        case .wiring:
            return "cable.connector"
        case .sensor:
            return "sensor"
        case .other:
            return "questionmark.circle"
        }
    }
}

struct HomeItem: Codable, Identifiable {
    let id: String
    let name: String
    let type: HomeItemType
    let isEmergency: Bool
    let data: AnyCodable?
    let createdAt: String
    let photoCount: Int
    let primaryPhotoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, data
        case isEmergency = "is_emergency"
        case createdAt = "created_at"
        case photoCount = "photo_count"
        case primaryPhotoUrl = "primary_photo_url"
    }
    
    init(id: String, name: String, type: HomeItemType, isEmergency: Bool, data: [String: Any]?, createdAt: String, photoCount: Int, primaryPhotoUrl: String?) {
        self.id = id
        self.name = name
        self.type = type
        self.isEmergency = isEmergency
        self.data = data.map(AnyCodable.init)
        self.createdAt = createdAt
        self.photoCount = photoCount
        self.primaryPhotoUrl = primaryPhotoUrl
    }
    
    var dataDict: [String: Any]? {
        return data?.value as? [String: Any]
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = ()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map(AnyCodable.init))
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues(AnyCodable.init))
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

struct CreateHomeItemRequest: Codable {
    let name: String
    let itemType: HomeItemType
    let isEmergency: Bool
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case name, isEmergency, data
        case itemType = "itemType"
    }
}

struct CreateHomeItemResponse: Codable {
    let id: String
    let homeId: String
    let name: String
    let type: HomeItemType
    let isEmergency: Bool
    let createdAt: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, isEmergency, message
        case homeId = "homeId"
        case createdAt = "createdAt"
    }
}

struct CreateHomeRequest: Codable {
    let address: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case address, role
    }
}

struct CreateHomeResponse: Codable {
    let id: String
    let address: String
    let role: String
    let createdAt: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id, address, role, message
        case createdAt = "created_at"
    }
}

struct PhotoUploadResponse: Codable {
    let id: String
    let homeItemId: String
    let fileName: String
    let s3Key: String
    let contentType: String?
    let caption: String?
    let message: String
    let photoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, fileName, s3Key, contentType, caption, message, photoUrl
        case homeItemId = "homeItemId"
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case unauthorized
    case forbidden
    case badRequest
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
        case .forbidden:
            return "Access forbidden"
        case .badRequest:
            return "Bad request"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}