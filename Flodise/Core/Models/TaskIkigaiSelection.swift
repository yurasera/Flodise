//
//  TaskIkigaiSelection.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 23/07/26.
//

import SwiftData

@Model
final class TaskIkigaiSelection {
    var typeRawValue: String

    var task: Task?

    init(type: IkigaiType, task: Task? = nil) {
        self.typeRawValue = type.rawValue
        self.task = task
    }

    var type: IkigaiType? {
        IkigaiType(rawValue: typeRawValue)
    }
}
