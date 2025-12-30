//
//  HomeTabView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAddHome = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Welcome Text (plain, no card)
                welcomeText

                // Homes Section
                homesSection

                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.background)
        .sheet(isPresented: $showingAddHome) {
            AddHomeView {
                // Refresh homes list when new home is added
                Task {
                    await authManager.refreshHomes()
                }
            }
            .environmentObject(authManager)
        }
        .onAppear {
            print("🏠 HomeTabView appeared")
            print("👤 Current user: \(authManager.backendUser?.name ?? "None")")
            print("🏠 Number of homes: \(authManager.homes.count)")
            
            if authManager.homes.isEmpty && !authManager.isLoading {
                print("🏠 Displaying empty state - no homes found")
            } else if !authManager.homes.isEmpty {
                print("🏠 Displaying \(authManager.homes.count) homes")
            } else {
                print("🔄 Loading homes...")
            }
        }
    }
    
    private var welcomeText: some View {
        HStack {
            if let backendUser = authManager.backendUser {
                Text("Welcome back, \(backendUser.name)")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            } else if authManager.isLoading {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading...")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }

            Spacer()
        }
    }
    
    private var homesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            if authManager.homes.isEmpty && !authManager.isLoading {
                // Empty state with Add Home button (allows adding first home)
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Your Homes")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("No homes found yet. Add your first home to get started!")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showingAddHome = true
                    }) {
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            HouseIconView(size: 48, systemName: "house.badge.plus")
                            
                            Text("Add New Home")
                                .font(DesignSystem.Typography.callout)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(DesignSystem.Spacing.xl)
                .cardStyle()
            } else if !authManager.homes.isEmpty {
                // Homes list
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Your Homes")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(authManager.homes) { home in
                            HomeCardView(home: home)
                                .onAppear {
                                    print("🏠 HomeCard appeared for: \(home.address ?? "Unknown address")")
                                }
                        }

                        // Add New Home button - REMOVED to limit users to 1 home
                        // Backend still supports multiple homes, just hiding the UI button
                        // Will be re-enabled later
                    }
                }
            } else {
                // Loading state
                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading your homes...")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.xl)
                .cardStyle()
            }
        }
    }
    
    private var addHomeButton: some View {
        Button(action: {
            showingAddHome = true
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                    .font(.title3)
                
                Text("Add New Home")
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .stroke(DesignSystem.Colors.primary, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, DesignSystem.Spacing.sm)
    }
    
}

#Preview {
    NavigationView {
        HomeTabView()
            .environmentObject(AuthenticationManager())
    }
}