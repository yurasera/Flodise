//
//  PriorityFilters.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import Foundation

enum CategoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case learn = "Learn"
    case projects = "Projects"
    case hobbies = "Hobbies"
    
    var id: String { rawValue }
}

enum ProgressFilter: String, CaseIterable, Identifiable {
    case active = "Active"
    case completed = "Completed"
    case archive = "Archive"
    
    var id: String { rawValue }
}
