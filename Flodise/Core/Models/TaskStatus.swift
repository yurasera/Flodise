//
//  TaskStatus.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

enum TaskStatus: String, Codable {
    case backlog
    case focus
    case completed
    case archive
    
    var title: String {
            switch self {
            case .backlog:
                return "Backlog"
            case .focus:
                return "Focus"
            case .completed:
                return "Completed"
            case .archive:
                return "Archive"
            }
        }
}
