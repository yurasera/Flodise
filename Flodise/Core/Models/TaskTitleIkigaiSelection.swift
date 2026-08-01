import SwiftData

@Model
final class TaskTitleIkigaiSelection {
    var typeRawValue: String
    var taskTitle: TaskTitle?

    init(type: IkigaiType, taskTitle: TaskTitle? = nil) {
        self.typeRawValue = type.rawValue
        self.taskTitle = taskTitle
    }

    var type: IkigaiType? { IkigaiType(rawValue: typeRawValue) }
}
