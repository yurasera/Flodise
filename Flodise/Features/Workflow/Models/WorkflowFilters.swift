//
//  PriorityFilters.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import Foundation

enum CategoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case current = "Current"
    case alternative = "Alternative"
    case dream = "Dream"
    
    var id: String { rawValue }
}

enum ProgressFilter: String, CaseIterable, Identifiable {
    case idea = "Idea"
    case planned = "Planned"
    case active = "Active"
    case completed = "Completed"
    case archive = "Archive"
    
    var id: String { rawValue }
}
