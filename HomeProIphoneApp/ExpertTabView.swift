//
//  ExpertTabView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 8/10/25.
//

import SwiftUI

struct ExpertTabView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Construction Icon
            Image(systemName: "cone.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.primary)
            
            // Under Construction Message
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Expert Services")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Under Construction")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("We're building something amazing! Expert services will connect you with trusted home professionals for maintenance, repairs, and improvements.")
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
                
                Text("Stay tuned for updates!")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
        .onAppear {
            print("👷 ExpertTabView appeared - Under Construction")
        }
    }
}

#Preview {
    ExpertTabView()
}