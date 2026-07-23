//
//  IkigaiType.swift
//  Flodise
//
//  Created by GitHub Copilot on 23/07/26.
//

import Foundation

enum IkigaiType: String, CaseIterable, Codable, Identifiable {
    case love
    case skill
    case need
    case paid

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .love: return "❤️"
        case .skill: return "🧠"
        case .need: return "🌍"
        case .paid: return "💰"
        }
    }

    var title: String {
        switch self {
        case .love: return "Love"
        case .skill: return "Skill"
        case .need: return "Need"
        case .paid: return "Paid"
        }
    }

    var description: String {
        switch self {
        case .love: return "Do what you enjoy"
        case .skill: return "Improve your abilities"
        case .need: return "Help others"
        case .paid: return "Earn income"
        }
    }
}