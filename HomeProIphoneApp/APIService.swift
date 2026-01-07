//
//  APIService.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import Foundation

class APIService: ObservableObject {
    static let shared = APIService()

    @Published private(set) var baseURL: String {
        didSet {
            UserDefaults.standard.set(baseURL, forKey: "APIBaseURL")
        }
    }

    private let defaultBaseURL = "https://home-owners.tech/api"
    private let baseURLKey = "APIBaseURL"

    // URLSession with timeout configuration
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0  // 30 seconds timeout
        config.timeoutIntervalForResource = 60.0  // 60 seconds total timeout
        return URLSession(configuration: config)
    }()
    
    private init() {
        // Load saved base URL or use default
        self.baseURL = UserDefaults.standard.string(forKey: baseURLKey) ?? defaultBaseURL
    }
    
    func setBaseURL(_ url: String) {
        baseURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func resetToDefaultURL() {
        baseURL = defaultBaseURL
    }
    
    func loginWithToken(_ firebaseToken: String) async throws -> BackendUser {
        guard let url = URL(string: "\(baseURL)/users/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("https://home-owners.tech/", forHTTPHeaderField: "Referer")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("cross-site", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        do {
            print("🌐 Making login request to: \(url.absoluteString)")
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Login response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Login response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    print("❌ No data received")
                    throw APIError.noData
                }
                
                do {
                    let backendUser = try JSONDecoder().decode(BackendUser.self, from: data)
                    print("✅ Successfully decoded BackendUser: \(backendUser)")
                    return backendUser
                } catch {
                    print("❌ Decoding error: \(error)")
                    print("📄 Raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    func getHomes(for userId: String, firebaseToken: String) async throws -> [Home] {
        guard let url = URL(string: "\(baseURL)/homes?userId=\(userId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do {
            print("🏠 Making homes request to: \(url.absoluteString)")
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid homes response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Homes response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Homes response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    print("📭 No homes data received")
                    return []
                }
                
                do {
                    let homes = try JSONDecoder().decode([Home].self, from: data)
                    print("✅ Successfully decoded \(homes.count) homes")
                    return homes
                } catch {
                    print("❌ Homes decoding error: \(error)")
                    print("📄 Raw homes data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    func getPhotos(for homeId: String, firebaseToken: String) async throws -> [Photo] {
        guard let url = URL(string: "\(baseURL)/photos?homeId=\(homeId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do {
            print("📸 Making photos request to: \(url.absoluteString)")
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid photos response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Photos response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Photos response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    print("📭 No photos data received")
                    return []
                }
                
                do {
                    let photos = try JSONDecoder().decode([Photo].self, from: data)
                    print("✅ Successfully decoded \(photos.count) photos")
                    return photos
                } catch {
                    print("❌ Photos decoding error: \(error)")
                    print("📄 Raw photos data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    func getHomeItems(for homeId: String, firebaseToken: String, type: HomeItemType? = nil, emergency: Bool? = nil, limit: Int = 50, offset: Int = 0) async throws -> [HomeItem] {
        var urlComponents = URLComponents(string: "\(baseURL)/homes/\(homeId)/items")!
        var queryItems: [URLQueryItem] = []
        
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if let emergency = emergency {
            queryItems.append(URLQueryItem(name: "emergency", value: String(emergency)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do {
            print("🏠 Making home items request to: \(url.absoluteString)")
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid home items response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Home items response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Home items response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    print("📭 No home items data received")
                    return []
                }
                
                do {
                    let homeItems = try JSONDecoder().decode([HomeItem].self, from: data)
                    print("✅ Successfully decoded \(homeItems.count) home items")
                    return homeItems
                } catch {
                    print("❌ Home items decoding error: \(error)")
                    print("📄 Raw home items data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }

    // Simple version that exactly matches the working curl request - no query parameters
    func getHomeItemsSimple(for homeId: String, firebaseToken: String) async throws -> [HomeItem] {
        guard let url = URL(string: "\(baseURL)/homes/\(homeId)/items") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("https://home-owners.tech/", forHTTPHeaderField: "Referer")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        do {
            print("🚨 Making SIMPLE home items request to: \(url.absoluteString)")
            print("🚨 Request headers: \(request.allHTTPHeaderFields ?? [:])")

            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid home items response type")
                throw APIError.networkError("Invalid response")
            }

            print("🚨 Simple home items response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("🚨 Simple home items response body: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    print("⚠️ Empty response data for home items")
                    return []
                }

                let homeItems = try JSONDecoder().decode([HomeItem].self, from: data)
                print("🚨 Successfully decoded \(homeItems.count) home items")

                // Log each item's emergency status
                for item in homeItems {
                    print("🚨   Item: \(item.name) - Emergency: \(item.isEmergency)")
                }

                return homeItems
            case 401:
                print("❌ Unauthorized (401) - Token might be expired")
                throw APIError.unauthorized
            case 403:
                print("❌ Forbidden (403) - Access denied")
                throw APIError.forbidden
            case 404:
                print("❌ Not Found (404) - Home might not exist")
                throw APIError.networkError("Home not found")
            default:
                print("❌ Server error (\(httpResponse.statusCode))")
                if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                    print("   Server error message: \(errorBody)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            }

        } catch {
            print("❌ Network or decoding error: \(error)")
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }

    func createHomeItem(for homeId: String, name: String, itemType: HomeItemType, isEmergency: Bool = false, data: String? = nil, firebaseToken: String) async throws -> CreateHomeItemResponse {
        guard let url = URL(string: "\(baseURL)/homes/\(homeId)/items") else {
            throw APIError.invalidURL
        }
        
        let requestBody = CreateHomeItemRequest(
            name: name,
            itemType: itemType,
            isEmergency: isEmergency,
            data: data
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            print("🏠 Making create home item request to: \(url.absoluteString)")
            print("📄 Request body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid create home item response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Create home item response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Create home item response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 201:
                guard !data.isEmpty else {
                    print("❌ No data received from create home item")
                    throw APIError.noData
                }
                
                do {
                    let createResponse = try JSONDecoder().decode(CreateHomeItemResponse.self, from: data)
                    print("✅ Successfully created home item: \(createResponse)")
                    return createResponse
                } catch {
                    print("❌ Create home item decoding error: \(error)")
                    print("📄 Raw create home item data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 400:
                throw APIError.badRequest
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    func getPhotosForHomeItem(homeItemId: String, firebaseToken: String) async throws -> [Photo] {
        guard let url = URL(string: "\(baseURL)/photos?homeItemId=\(homeItemId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do {
            print("📸 Making home item photos request to: \(url.absoluteString)")
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid home item photos response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Home item photos response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Home item photos response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    print("📭 No home item photos data received")
                    return []
                }
                
                do {
                    let photos = try JSONDecoder().decode([Photo].self, from: data)
                    print("✅ Successfully decoded \(photos.count) home item photos")
                    return photos
                } catch {
                    print("❌ Home item photos decoding error: \(error)")
                    print("📄 Raw home item photos data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    func uploadPhotoForHomeItem(homeItemId: String, imageData: Data, fileName: String, firebaseToken: String) async throws -> PhotoUploadResponse {
        guard let url = URL(string: "\(baseURL)/photos?homeItemId=\(homeItemId)") else {
            throw APIError.invalidURL
        }
        
        // Create a more standard boundary format
        let boundary = "----WebKitFormBoundary\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
        // Determine content type based on file extension (defaulting to JPEG like most camera photos)
        let contentType: String
        if fileName.lowercased().hasSuffix(".png") {
            contentType = "image/png"
        } else if fileName.lowercased().hasSuffix(".gif") {
            contentType = "image/gif"
        } else if fileName.lowercased().hasSuffix(".webp") {
            contentType = "image/webp"
        } else {
            contentType = "image/jpeg"
        }
        
        // Create multipart form data exactly like curl -F does
        var body = Data()
        
        // Opening boundary
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        // Form field headers - exactly matching curl format
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(contentType)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // File content
        body.append(imageData)
        
        // Closing boundary
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📸 Upload details:")
        print("   🔗 URL: \(url.absoluteString)")
        print("   📝 Filename: \(fileName)")
        print("   📄 Content-Type: \(contentType)")
        print("   📦 Image data size: \(imageData.count) bytes")
        print("   📦 Total body size: \(body.count) bytes")
        print("   🔖 Boundary: \(boundary)")
        print("   🔑 Auth token: Bearer \(firebaseToken.prefix(10))...")
        
        // Log raw body structure for debugging
        if let bodyString = String(data: body.prefix(500), encoding: .utf8) {
            print("   📄 Body preview (first 500 chars):")
            print(bodyString.replacingOccurrences(of: "\r\n", with: "\\r\\n"))
        }
        
        do {
            print("📸 Making upload photo request to: \(url.absoluteString)")
            print("📄 Uploading file: \(fileName) (\(imageData.count) bytes)")
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid upload photo response type")
                throw APIError.networkError("Invalid response")
            }
            
            print("📱 Upload photo response status: \(httpResponse.statusCode)")
            print("📄 Response headers: \(httpResponse.allHeaderFields)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Upload photo response body: \(responseString)")
            } else {
                print("📄 Upload photo response body: <binary or empty data>")
            }
            
            switch httpResponse.statusCode {
            case 200, 201:
                guard !data.isEmpty else {
                    print("❌ No data received from upload photo")
                    throw APIError.noData
                }
                
                do {
                    let uploadResponse = try JSONDecoder().decode(PhotoUploadResponse.self, from: data)
                    print("✅ Successfully uploaded photo: \(uploadResponse)")
                    return uploadResponse
                } catch {
                    print("❌ Upload photo decoding error: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("❌ Specific decoding error: \(decodingError)")
                    }
                    print("📄 Raw upload photo data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
                
            case 400:
                print("❌ Bad Request (400) - Check request format")
                if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                    print("   Server error message: \(errorBody)")
                }
                throw APIError.badRequest
            case 401:
                print("❌ Unauthorized (401) - Check authentication token")
                throw APIError.unauthorized
            case 403:
                print("❌ Forbidden (403) - Check permissions")
                throw APIError.forbidden
            case 413:
                print("❌ Payload Too Large (413) - Image might be too big")
                throw APIError.networkError("Image file is too large")
            case 415:
                print("❌ Unsupported Media Type (415) - Check image format")
                throw APIError.networkError("Unsupported image format")
            case 422:
                print("❌ Unprocessable Entity (422) - Validation error")
                if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                    print("   Server validation error: \(errorBody)")
                }
                throw APIError.networkError("Validation error: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
            default:
                print("❌ Server error (\(httpResponse.statusCode))")
                if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                    print("   Server error message: \(errorBody)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            print("❌ Network or other error during upload: \(error)")
            if error is APIError {
                throw error
            } else {
                print("❌ Raw error details: \(error)")
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
    
    func createHome(address: String, role: String = "owner", firebaseToken: String) async throws -> CreateHomeResponse {
        guard let url = URL(string: "\(baseURL)/homes") else {
            throw APIError.invalidURL
        }

        let requestBody = CreateHomeRequest(address: address, role: role)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData

            print("🏠 Making create home request to: \(url.absoluteString)")
            print("📄 Request body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")

            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid create home response type")
                throw APIError.networkError("Invalid response")
            }

            print("📱 Create home response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Create home response body: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 201:
                guard !data.isEmpty else {
                    print("❌ No data received from create home")
                    throw APIError.noData
                }

                do {
                    let createResponse = try JSONDecoder().decode(CreateHomeResponse.self, from: data)
                    print("✅ Successfully created home: \(createResponse)")
                    return createResponse
                } catch {
                    print("❌ Create home decoding error: \(error)")
                    print("📄 Raw create home data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }

            case 400:
                throw APIError.badRequest
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }

        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }

    func deleteHomeItem(homeId: String, itemId: String, firebaseToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/homes/\(homeId)/items/\(itemId)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        do {
            print("🗑️ DELETE HOME ITEM DEBUG:")
            print("   🔗 URL: \(url.absoluteString)")
            print("   🏠 Home ID: \(homeId)")
            print("   📦 Item ID: \(itemId)")
            print("   🔑 Token (first 20 chars): \(firebaseToken.prefix(20))...")
            print("   📋 All headers: \(request.allHTTPHeaderFields ?? [:])")

            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid delete home item response type")
                throw APIError.networkError("Invalid response")
            }

            print("📱 Delete home item response status: \(httpResponse.statusCode)")
            if !data.isEmpty, let responseString = String(data: data, encoding: .utf8) {
                print("📄 Delete home item response body: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 204:
                print("✅ Successfully deleted home item")
                return

            case 401:
                throw APIError.unauthorized
            case 403:
                print("❌ Forbidden (403) - User doesn't have access to this home or item")
                if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                    print("   Server error message: \(errorBody)")
                }
                throw APIError.forbidden
            case 404:
                print("❌ Not Found (404) - Home item not found")
                throw APIError.networkError("Home item not found")
            default:
                print("❌ Server error (\(httpResponse.statusCode))")
                if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                    print("   Server error message: \(errorBody)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            }

        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }
}