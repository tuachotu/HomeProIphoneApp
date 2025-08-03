//
//  InviteOnlyView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct InviteOnlyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primaryLight)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "envelope.badge")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                // Title and description
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Invite Only")
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("HomePro is currently in private beta.")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("We're carefully onboarding new users to ensure the best experience.")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // Contact info card
            VStack(spacing: DesignSystem.Spacing.lg) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Want an invite?")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "at")
                                .foregroundColor(DesignSystem.Colors.primary)
                                .font(.system(size: 16))
                            
                            Text("Follow and DM us on Twitter")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Button {
                            openTwitter()
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "link")
                                    .font(.system(size: 14))
                                Text("@vikkrraant")
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
                .cardStyle()
            }
            
            // Action buttons
            VStack(spacing: DesignSystem.Spacing.md) {
                Button {
                    openTwitter()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "paperplane")
                        Text("Contact for Invite")
                    }
                    .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                
                Button("Close") {
                    dismiss()
                }
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .padding(.top, DesignSystem.Spacing.sm)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.top, DesignSystem.Spacing.xxl)
        .background(DesignSystem.Colors.background)
    }
    
    private func openTwitter() {
        let twitterURL = URL(string: "twitter://user?screen_name=vikkrraant")
        let webURL = URL(string: "https://twitter.com/vikkrraant")
        
        if let twitterURL = twitterURL, UIApplication.shared.canOpenURL(twitterURL) {
            UIApplication.shared.open(twitterURL)
        } else if let webURL = webURL {
            UIApplication.shared.open(webURL)
        }
    }
}

#Preview {
    InviteOnlyView()
}