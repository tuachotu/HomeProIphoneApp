//
//  WelcomeView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingProfileDetails = false
    @State private var showingFeatures = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header Section
                headerSection
                
                // Profile Card
                profileCard
                
                // Features Preview (Collapsible)
                featuresSection
                
                // Quick Actions
                quickActionsSection
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.xl)
        }
        .background(DesignSystem.Colors.background)
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Welcome to HomePro")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("The trusted friend your home always needed")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var profileCard: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            HStack {
                HouseIconView(
                    size: 60,
                    systemName: authManager.backendUser?.isHomeOwner == true ? "house" : "person"
                )
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    if let backendUser = authManager.backendUser {
                        Text("Hello, \(backendUser.name)!")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.success)
                                .font(.caption)
                            Text(backendUser.roleDisplayName)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    } else if authManager.isLoading {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading profile...")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingProfileDetails.toggle()
                    }
                } label: {
                    Image(systemName: showingProfileDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            
            if showingProfileDetails {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Divider()
                    
                    if let userEmail = authManager.user?.email {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text(userEmail)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Spacer()
                        }
                    }
                    
                    if let error = authManager.authError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(DesignSystem.Colors.error)
                            Text(error)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.error)
                            Spacer()
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var featuresSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingFeatures.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Coming Soon")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Explore upcoming HomePro features")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: showingFeatures ? "chevron.up" : "chevron.down")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showingFeatures {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Divider()
                    
                    featureRow(icon: "wrench.and.screwdriver", title: "Service Requests", description: "Book home maintenance services")
                    featureRow(icon: "doc.text", title: "Project Management", description: "Track home improvement projects")
                    featureRow(icon: "calendar", title: "Maintenance Schedule", description: "Never miss important home tasks")
                    featureRow(icon: "person.2", title: "Trusted Professionals", description: "Connect with verified contractors")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.Colors.primary)
                .font(.system(size: 16))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(description)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button {
                logout()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .frame(maxWidth: .infinity)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.error)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.cardBackground)
                .cornerRadius(DesignSystem.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(DesignSystem.Colors.error.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private func logout() {
        do {
            try authManager.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}