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
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
