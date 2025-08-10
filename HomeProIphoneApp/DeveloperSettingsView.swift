//
//  DeveloperSettingsView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/9/25.
//

import SwiftUI

struct DeveloperSettingsView: View {
    @State private var customBaseURL: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var cacheSize: String = "Calculating..."
    @Environment(\.dismiss) private var dismiss
    
    let predefinedURLs = [
        ("Production", "https://api.homepro.com"),
        ("Home Owners Tech", "https://home-owners.tech/api"),
        ("Local Development", "http://localhost:2107")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("Developer Settings")
                            .font(DesignSystem.Typography.title1)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Configure API base URL")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    
                    // Current URL Display
                    currentURLSection
                    
                    // Custom URL Input (moved up for better keyboard accessibility)
                    customURLSection
                    
                    // Quick Select URLs
                    quickSelectSection
                    
                    // Image Cache Management
                    imageCacheSection
                    
                    // Add extra padding at bottom for keyboard
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                // Dismiss keyboard when tapping outside text fields
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                updateCacheSize()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .alert("Settings Updated", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            customBaseURL = APIService.shared.baseURL
        }
    }
    
    private var currentURLSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Current API Base URL")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(APIService.shared.baseURL)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .padding(DesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DesignSystem.Colors.offWhite)
                    .cornerRadius(DesignSystem.CornerRadius.sm)
                
                Text("This is the URL the app will use for API requests")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var quickSelectSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Quick Select")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(predefinedURLs.enumerated()), id: \.offset) { index, urlInfo in
                    Button {
                        setBaseURL(urlInfo.1, name: urlInfo.0)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(urlInfo.0)
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text(urlInfo.1)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if APIService.shared.baseURL == urlInfo.1 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(DesignSystem.Colors.success)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.cardBackground)
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(
                                    APIService.shared.baseURL == urlInfo.1 ? 
                                    DesignSystem.Colors.primary : DesignSystem.Colors.paleGray,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var customURLSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Custom URL")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                TextField("Enter custom API base URL", text: $customBaseURL)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.callout)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .submitLabel(.done)
                    .onSubmit {
                        if isValidURL(customBaseURL) {
                            setBaseURL(customBaseURL, name: "Custom")
                        }
                    }
                    .inputFieldStyle()
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Button {
                        customBaseURL = APIService.shared.baseURL
                    } label: {
                        Text("Reset")
                    }
                    .secondaryButtonStyle()
                    
                    Button {
                        if isValidURL(customBaseURL) {
                            setBaseURL(customBaseURL, name: "Custom")
                        } else {
                            alertMessage = "Please enter a valid URL (e.g., https://api.example.com)"
                            showingAlert = true
                        }
                    } label: {
                        Text("Apply Custom URL")
                    }
                    .primaryButtonStyle()
                    .disabled(customBaseURL.isEmpty || customBaseURL == APIService.shared.baseURL)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var imageCacheSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Image Cache")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Manage cached home images")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cache Size")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(cacheSize)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button {
                    updateCacheSize()
                } label: {
                    Text("Refresh")
                        .font(DesignSystem.Typography.caption)
                }
                .secondaryButtonStyle()
            }
            
            Button {
                clearImageCache()
            } label: {
                Text("Clear Image Cache")
            }
            .primaryButtonStyle()
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private func updateCacheSize() {
        cacheSize = ImageCacheManager.shared.getCacheSize()
        print("🗄️ Updated cache size: \(cacheSize)")
    }
    
    private func clearImageCache() {
        ImageCacheManager.shared.clearCache()
        updateCacheSize()
        alertMessage = "Image cache cleared successfully"
        showingAlert = true
        print("🗑️ Image cache cleared by user")
    }

    private func setBaseURL(_ url: String, name: String) {
        APIService.shared.setBaseURL(url)
        customBaseURL = url
        alertMessage = "Base URL set to \(name): \(url)"
        showingAlert = true
    }
    
    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              let host = url.host,
              !host.isEmpty else {
            return false
        }
        return true
    }
}