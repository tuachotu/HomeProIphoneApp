//
//  DesignSystem.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Light neutrals
        static let background = Color(.systemGroupedBackground)
        static let cardBackground = Color.white
        static let offWhite = Color(red: 0.98, green: 0.98, blue: 0.99)
        static let paleGray = Color(red: 0.95, green: 0.95, blue: 0.96)
        
        // Soft blues
        static let primary = Color(red: 0.34, green: 0.56, blue: 0.89) // Soft blue
        static let primaryLight = Color(red: 0.87, green: 0.92, blue: 0.98) // Very light blue
        static let accent = Color(red: 0.20, green: 0.40, blue: 0.75) // Deeper blue for accents
        
        // Text colors
        static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.18)
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.50)
        static let textTertiary = Color(red: 0.65, green: 0.65, blue: 0.70)
        
        // Semantic colors
        static let error = Color(red: 0.90, green: 0.30, blue: 0.30)
        static let success = Color(red: 0.20, green: 0.70, blue: 0.40)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 32, weight: .light, design: .default)
        static let title1 = Font.system(size: 26, weight: .medium, design: .default)
        static let title2 = Font.system(size: 20, weight: .medium, design: .default)
        static let headline = Font.system(size: 16, weight: .medium, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let callout = Font.system(size: 15, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}

// MARK: - Custom View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func inputFieldStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.offWhite)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(DesignSystem.Colors.paleGray, lineWidth: 1)
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.sm)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(DesignSystem.Colors.primaryLight)
            .cornerRadius(DesignSystem.CornerRadius.sm)
    }
}