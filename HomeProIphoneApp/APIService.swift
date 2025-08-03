//
//  APIService.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://home-owners.tech/api"
    
    private init() {}
    
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
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError("Invalid response")
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard !data.isEmpty else {
                    throw APIError.noData
                }
                
                do {
                    let backendUser = try JSONDecoder().decode(BackendUser.self, from: data)
                    return backendUser
                } catch {
                    print("Decoding error: \(error)")
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