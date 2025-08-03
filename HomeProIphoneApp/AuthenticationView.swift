//
//  AuthenticationView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        NavigationStack {
            if authManager.user != nil {
                WelcomeView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}