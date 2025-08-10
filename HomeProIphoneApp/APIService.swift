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
            let (data, response) = try await URLSession.shared.data(for: request)
            
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
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
}