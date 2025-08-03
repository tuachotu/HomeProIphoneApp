//
//  LoginView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showingInviteOnly = false
    @State private var showingPasswordReset = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                    
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        HouseIconView(size: 80)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("HomePro")
                                .font(DesignSystem.Typography.largeTitle)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("The trusted friend your home always needed")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                
                // Login Form
                VStack(spacing: DesignSystem.Spacing.xl) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            TextField("Email address", text: $email)
                                .font(DesignSystem.Typography.body)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .inputFieldStyle()
                            
                            SecureField("Password", text: $password)
                                .font(DesignSystem.Typography.body)
                                .textContentType(.password)
                                .inputFieldStyle()
                        }
                        
                        if !errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(DesignSystem.Colors.error)
                                Text(errorMessage)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.error)
                                Spacer()
                            }
                        }
                    }
                    
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Button {
                            Task { await signIn() }
                        } label: {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .primaryButtonStyle()
                        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                        
                        Button {
                            showingInviteOnly = true
                        } label: {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                        }
                        .secondaryButtonStyle()
                        
                        Button("Forgot Password?") {
                            showingPasswordReset = true
                        }
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .padding(.top, DesignSystem.Spacing.sm)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.top, DesignSystem.Spacing.xxl)
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
        }
        .background(DesignSystem.Colors.background)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingInviteOnly) {
            InviteOnlyView()
        }
        .sheet(isPresented: $showingPasswordReset) {
            PasswordResetView()
                .environmentObject(authManager)
        }
    }
    
    private func signIn() async {
        errorMessage = ""
        
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}