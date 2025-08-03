//
//  HouseIconView.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/2/25.
//

import SwiftUI

struct HouseIconView: View {
    let size: CGFloat
    let iconSize: CGFloat
    let systemName: String
    
    init(
        size: CGFloat = 80,
        iconSize: CGFloat? = nil,
        systemName: String = "house"
    ) {
        self.size = size
        self.iconSize = iconSize ?? (size * 0.5)
        self.systemName = systemName
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Colors.primaryLight)
                .frame(width: size, height: size)
            
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .light))
                .foregroundColor(DesignSystem.Colors.primary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HouseIconView(size: 60)
        HouseIconView(size: 80)
        HouseIconView(size: 100, systemName: "person")
    }
    .padding()
    .background(DesignSystem.Colors.background)
}