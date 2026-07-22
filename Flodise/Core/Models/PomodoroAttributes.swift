import ActivityKit
import Foundation

enum PomodoroSessionState: String, Codable {
    case running
    case paused
    case finished
}

struct PomodoroAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sessionName: String
        var remainingTime: TimeInterval
        var totalDuration: TimeInterval
        var startDate: Date
        var endDate: Date
        var progress: Double
        var state: PomodoroSessionState
    }

    var taskId: String
    var taskTitle: String
    var taskCategory: String?
}
