//
//  AuthenticationManager.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import Foundation
import FirebaseAuth
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var backendUser: BackendUser?
    @Published var homes: [Home] = []
    @Published var isLoading = false
    @Published var authError: String?
    
    init() {
        print("🔐 AuthenticationManager initializing...")
        
        // Firebase automatically persists authentication state
        user = Auth.auth().currentUser
        
        if let currentUser = user {
            print("👤 Found existing Firebase user: \(currentUser.email ?? "unknown")")
        } else {
            print("🚫 No existing Firebase user found")
        }
        
        // If user is already logged in, authenticate with backend
        if user != nil {
            print("🔄 Starting backend authentication for existing user...")
            Task {
                await authenticateWithBackend()
            }
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    print("📱 Firebase auth state changed - User logged in: \(user.email ?? "unknown")")
                } else {
                    print("📱 Firebase auth state changed - User logged out")
                }
                
                self?.user = user
                if user != nil {
                    Task {
                        await self?.authenticateWithBackend()
                    }
                } else {
                    self?.backendUser = nil
                    self?.homes = []
                }
            }
        }
        
        print("✅ AuthenticationManager initialized")
    }
    
    func signUp(email: String, password: String) async throws {
        print("📝 Starting sign up for email: \(email)")
        isLoading = true
        authError = nil
        defer { 
            isLoading = false 
            print("🔄 Sign up loading state set to false")
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ Firebase sign up successful for: \(email)")
            
            DispatchQueue.main.async {
                self.user = result.user
            }
            
            await authenticateWithBackend()
        } catch {
            print("❌ Firebase sign up failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("🔑 Starting sign in for email: \(email)")
        isLoading = true
        authError = nil
        defer { 
            isLoading = false 
            print("🔄 Sign in loading state set to false")
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Firebase sign in successful for: \(email)")
            
            DispatchQueue.main.async {
                self.user = result.user
            }
            
            await authenticateWithBackend()
        } catch {
            print("❌ Firebase sign in failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        print("🔄 Starting password reset for email: \(email)")
        isLoading = true
        defer { 
            isLoading = false 
            print("🔄 Password reset loading state set to false")
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("✅ Password reset email sent successfully to: \(email)")
        } catch {
            print("❌ Password reset failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        print("🚪 Starting sign out...")
        
        do {
            try Auth.auth().signOut()
            print("✅ Firebase sign out successful")
            
            DispatchQueue.main.async {
                self.user = nil
                self.backendUser = nil
                self.homes = []
                self.authError = nil
                print("🧹 User state cleared")
            }
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func refreshHomes() async {
        guard let user = user, let backendUser = backendUser else {
            print("❌ Cannot refresh homes - user not authenticated")
            return
        }
        
        do {
            print("🔄 Refreshing homes...")
            let firebaseToken = try await user.getIDToken()
            await fetchHomes(userId: backendUser.id, firebaseToken: firebaseToken)
        } catch {
            print("❌ Error refreshing homes: \(error)")
            await MainActor.run {
                authError = "Failed to refresh homes: \(error.localizedDescription)"
            }
        }
    }
    
    private func authenticateWithBackend() async {
        print("🔗 Starting backend authentication...")
        guard let firebaseUser = user else { 
            print("❌ No Firebase user available for backend auth")
            return 
        }
        
        print("🔑 Getting Firebase ID token for user: \(firebaseUser.email ?? "unknown")")
        
        do {
            let idToken = try await firebaseUser.getIDToken()
            print("✅ Firebase ID token obtained successfully")
            
            let backendUserResponse = try await APIService.shared.loginWithToken(idToken)
            print("✅ Backend login successful for user: \(backendUserResponse.name)")
            
            DispatchQueue.main.async {
                self.backendUser = backendUserResponse
                self.authError = nil
                print("📱 Backend user state updated in UI")
            }
            
            // Fetch user's homes
            print("🏠 Starting to fetch homes for user: \(backendUserResponse.id)")
            await fetchHomes(userId: backendUserResponse.id, firebaseToken: idToken)
            
        } catch {
            print("❌ Backend authentication failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
            }
        }
    }
    
    private func fetchHomes(userId: String, firebaseToken: String) async {
        print("🏠 Fetching homes for user ID: \(userId)")
        
        do {
            let homesResponse = try await APIService.shared.getHomes(for: userId, firebaseToken: firebaseToken)
            print("✅ Successfully fetched \(homesResponse.count) homes")
            
            for (index, home) in homesResponse.enumerated() {
                print("🏠 Home \(index + 1): \(home.address ?? "Unknown address") - Role: \(home.role)")
                print("   📊 Stats: \(home.stats.totalItems) items, \(home.stats.totalPhotos) photos, \(home.stats.emergencyItems) emergency")
            }
            
            DispatchQueue.main.async {
                self.homes = homesResponse
                print("📱 Homes updated in UI (\(homesResponse.count) homes)")
            }
        } catch {
            print("❌ Error fetching homes: \(error.localizedDescription)")
        }
    }
}