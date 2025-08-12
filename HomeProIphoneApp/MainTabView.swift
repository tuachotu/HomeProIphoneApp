//
//  MainTabView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    @State private var showingEmergencyInfo = false
    @State private var selectedHomeForEmergency: Home?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Expert Tab (Under Construction)
            ExpertTabView()
                .tabItem {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                    Text("Expert")
                }
                .tag(1)
            
            // Resources Tab (Under Construction)
            ResourcesTabView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Resources")
                }
                .tag(2)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("HomePro")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                emergencyButton
            }
        }
        .sheet(isPresented: $showingEmergencyInfo) {
            EmergencyInfoView(
                home: selectedHomeForEmergency ?? defaultHome,
                selectedTab: selectedTab
            )
        }
        .onAppear {
            print("📱 MainTabView appeared - Selected tab: \(selectedTab)")
        }
        .sequentialTapDeveloperGesture()
    }
    
    private var emergencyButton: some View {
        Button {
            print("🚨 Emergency button tapped")
            selectedHomeForEmergency = primaryHome
            showingEmergencyInfo = true
        } label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DesignSystem.Colors.error)
                .font(.system(size: 20, weight: .bold))
        }
        .accessibilityLabel("Emergency Information")
        .accessibilityHint("Tap to view emergency details for your home")
    }
    
    // Get the primary home (first home or first one marked as primary)
    private var primaryHome: Home? {
        authManager.homes.first
    }
    
    // Default home for emergency info (in case no homes are loaded yet)
    private var defaultHome: Home {
        Home(
            id: "default",
            address: "Loading...",
            role: "owner",
            createdAt: "",
            updatedAt: "",
            stats: HomeStats(totalItems: 0, totalPhotos: 0, emergencyItems: 0)
        )
    }
}

#Preview {
    NavigationView {
        MainTabView()
            .environmentObject(AuthenticationManager())
    }
}