//
//  SignUpView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        HouseIconView(size: 60)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Create Account")
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Join HomePro to get started")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    
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
                                .textContentType(.newPassword)
                                .inputFieldStyle()
                            
                            SecureField("Confirm password", text: $confirmPassword)
                                .font(DesignSystem.Typography.body)
                                .textContentType(.newPassword)
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
                        
                        Button {
                            Task { await signUp() }
                        } label: {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .primaryButtonStyle()
                        .disabled(authManager.isLoading || !isValidForm)
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUp() async {
        errorMessage = ""
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        do {
            try await authManager.signUp(email: email, password: password)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}