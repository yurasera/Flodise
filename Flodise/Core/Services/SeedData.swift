//
//  SeedData.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftData

@MainActor
enum SeedData {

    static func seedCategories(in context: ModelContext) throws {

        let descriptor = FetchDescriptor<Category>()

        let categories = try context.fetch(descriptor)

        guard categories.isEmpty else {
            return
        }

        context.insert(Category(name: "Current Path", color: "blue"))
        context.insert(Category(name: "Alternative Path", color: "green"))
        context.insert(Category(name: "Dream Path", color: "yellow"))

        try context.save()
    }

}
