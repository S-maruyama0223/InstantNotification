//
//  RemindTableViewModel.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/27.
//  
//

import Foundation

protocol TaskModelDelegate: AnyObject {
    func registerTask(record: TaskCellRecord)
}

class TaskModel {
    var tasks = [TaskCellRecord]()
    weak var delegate: TaskModelDelegate?

    func createRecord(hour: String, minute: String, task: String) {
        delegate?.registerTask(record: TaskCellRecord(task: task, time: "\(hour):\(minute)"))
    }
}

struct TaskCellRecord {
    let task: String
    let time: String
}
