//
//  PasswordResetView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        HouseIconView(size: 60, systemName: "lock.rotation")
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Reset Password")
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Enter your email address and we'll send you a link to reset your password.")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        TextField("Email address", text: $email)
                            .font(DesignSystem.Typography.body)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .inputFieldStyle()
                        
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
                        
                        if !successMessage.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(DesignSystem.Colors.success)
                                Text(successMessage)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.success)
                                Spacer()
                            }
                        }
                        
                        Button {
                            Task { await resetPassword() }
                        } label: {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Send Reset Email")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .primaryButtonStyle()
                        .disabled(authManager.isLoading || email.isEmpty)
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Reset Password")
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
    
    private func resetPassword() async {
        errorMessage = ""
        successMessage = ""
        
        do {
            try await authManager.resetPassword(email: email)
            successMessage = "Password reset email sent. Check your inbox."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}