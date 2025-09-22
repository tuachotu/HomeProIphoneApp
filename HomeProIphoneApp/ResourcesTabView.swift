//
//  ResourcesTabView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import SwiftUI

struct ResourcesTabView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Construction Icon
            Image(systemName: "hammer.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.primary)
            
            // Under Construction Message
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Home Resources")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Under Construction")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("Your home management hub is being built! Access guides, maintenance schedules, warranty information, and helpful resources all in one place.")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            // Coming Soon Badge
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Coming Soon")
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                    )
                
                Text("Helpful resources coming your way!")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .onAppear {
            print("📚 ResourcesTabView appeared - Under Construction")
        }
    }
}

#Preview {
    ResourcesTabView()
}