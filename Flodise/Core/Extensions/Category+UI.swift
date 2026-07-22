//
//  Category+UI.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftUI

extension Category {

    var headerColor: Color {
        switch color {
        case "blue":
            return .brandTertiary

        case "green":
            return .brandTertiary

        case "yellow":
            return .brandSecondary

        default:
            return .gray
        }
    }

    var backgroundColor: Color {
        switch color {
        case "blue":
            return .brandPrimary

        case "green":
            return .brandSecondary

        case "yellow":
            return .brandTertiary

        default:
            return .gray
        }
    }
}
