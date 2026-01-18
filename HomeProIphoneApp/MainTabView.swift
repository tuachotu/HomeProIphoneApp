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
    @State private var showingMenu = false
    
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
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text("HomePro")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary)

                    Button {
                        showingMenu = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
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
            .environmentObject(authManager)
        }
        .sheet(isPresented: $showingMenu) {
            menuView
        }
        .onAppear {
            print("📱 MainTabView appeared - Selected tab: \(selectedTab)")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("📱 App became active - refreshing state")
            // Reset any stuck loading states
            Task {
                await authManager.refreshAppState()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("📱 App entered background")
        }
        .sequentialTapDeveloperGesture()
    }
    
    private var emergencyButton: some View {
        Button {
            print("🚨 Emergency button tapped")
            selectedHomeForEmergency = primaryHome
            showingEmergencyInfo = true
        } label: {
            Text("Get Help Now")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.error)
                )
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
            name: "Loading...",
            address: nil,
            role: "owner",
            createdAt: "",
            updatedAt: "",
            stats: HomeStats(totalItems: 0, totalPhotos: 0, emergencyItems: 0)
        )
    }

    private var menuView: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Menu Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Menu")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
                .padding(.horizontal, DesignSystem.Spacing.lg)

                Divider()

                // Menu Options
                VStack(spacing: 0) {
                    // Sign Out Option
                    Button {
                        showingMenu = false
                        signOut()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title3)
                                .foregroundColor(DesignSystem.Colors.error)
                                .frame(width: 24)

                            Text("Sign Out")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.error)

                            Spacer()
                        }
                        .padding(.vertical, DesignSystem.Spacing.lg)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .background(DesignSystem.Colors.background)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider()
                        .padding(.leading, DesignSystem.Spacing.lg)

                    // Help Option (Disabled)
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .frame(width: 24)

                        Text("Help")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        Spacer()

                        Text("Coming Soon")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }

                Spacer()
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingMenu = false
                    }
                }
            }
        }
    }

    private func signOut() {
        print("🚪 User initiated sign out from menu")
        do {
            try authManager.signOut()
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationView {
        MainTabView()
            .environmentObject(AuthenticationManager())
    }
}