//
//  DatabaseManager.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 26/07/26.
//

import Foundation
import SwiftData
import OSLog

enum DatabaseManager {
    private static let logger = Logger(subsystem: "com.yuhayalissera.Flocus", category: "DatabaseManager")

    static func makeContainer() throws -> ModelContainer {
        do {
            let container = try ModelContainer(for: Category.self, Task.self)
            try seedDataIfNeeded(in: ModelContext(container))
            return container
        } catch {
            Self.logger.critical("Failed to initialize SwiftData container: \(error)")
            throw error
        }
    }

    private static func seedDataIfNeeded(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<Category>()
        let categories = try context.fetch(descriptor)

        guard categories.isEmpty else {
            return
        }

        context.insert(Category(name: "Current", color: "blue"))
        context.insert(Category(name: "Alternative", color: "green"))
        context.insert(Category(name: "Dream", color: "yellow"))

        try context.save()
    }
}
