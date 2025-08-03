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
    @Published var isLoading = false
    @Published var authError: String?
    
    init() {
        // Firebase automatically persists authentication state
        user = Auth.auth().currentUser
        
        // If user is already logged in, authenticate with backend
        if user != nil {
            Task {
                await authenticateWithBackend()
            }
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                if user != nil {
                    Task {
                        await self?.authenticateWithBackend()
                    }
                } else {
                    self?.backendUser = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.user = result.user
        }
        
        await authenticateWithBackend()
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.user = result.user
        }
        
        await authenticateWithBackend()
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        DispatchQueue.main.async {
            self.user = nil
            self.backendUser = nil
            self.authError = nil
        }
    }
    
    private func authenticateWithBackend() async {
        guard let firebaseUser = user else { return }
        
        do {
            let idToken = try await firebaseUser.getIDToken()
            let backendUserResponse = try await APIService.shared.loginWithToken(idToken)
            
            DispatchQueue.main.async {
                self.backendUser = backendUserResponse
                self.authError = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
                print("Backend authentication error: \(error)")
            }
        }
    }
}