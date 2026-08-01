//
//  TaskTitle.swift
//  Flodise
//

import Foundation
import SwiftData

@Model
final class TaskTitle {
    var title: String
    var isSelected: Bool
    var createdAt: Date

    init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
        self.createdAt = .now
    }
}
