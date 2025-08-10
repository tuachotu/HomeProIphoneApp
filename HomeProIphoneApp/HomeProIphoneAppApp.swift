//
//  HomeProIphoneAppApp.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI
import FirebaseCore

@main
struct HomeProIphoneAppApp: App {
    
    init() {
        print("🚀 HomePro app starting up...")
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
