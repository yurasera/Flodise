//
//  Color+Extensions.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 23/06/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
    
    // Brand
    static let brandPrimary = Color(hex: "#2258C7")
    static let brandSecondary = Color(hex: "#8CC0FA")
    static let brandTertiary = Color(hex: "#FAFEFF")

    // Surface
    static let surface = Color(hex: "#F8F8F8")
    static let surfaceSecondary = Color(hex: "#EEEEEE")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
}
