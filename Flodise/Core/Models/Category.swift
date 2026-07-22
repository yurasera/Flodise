//
//  Category.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftData

@Model
final class Category {

    var name: String
    var color: String
    @Relationship(deleteRule: .cascade)
    var tasks: [Task]

    init(name: String, color: String, tasks: [Task] = []) {
        self.name = name
        self.color = color
        self.tasks = []
    }

}
