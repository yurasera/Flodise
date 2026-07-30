//
//  Category.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftData
import Foundation

@Model
final class Category {

    var name: String
    var color: String
    var subtitle: String?
    @Relationship(deleteRule: .cascade)
    var tasks: [Task]

    init(name: String, color: String, subtitle: String? = nil, tasks: [Task] = []) {
        self.name = name
        self.color = color
        let trimmedSubtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.subtitle = (trimmedSubtitle?.isEmpty == false) ? trimmedSubtitle : Self.defaultSubtitle(for: name)
        self.tasks = []
    }

}

extension Category {
    var displaySubtitle: String {
        let trimmedSubtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmedSubtitle, !trimmedSubtitle.isEmpty else {
            return Self.defaultSubtitle(for: name)
        }

        return trimmedSubtitle
    }

    static func defaultSubtitle(for title: String) -> String {
        switch title {
        case "Current":
            return "Engineer"
        case "Alternative":
            return "Educator"
        case "Dream":
            return "Builder"
        default:
            return title
        }
    }
}
