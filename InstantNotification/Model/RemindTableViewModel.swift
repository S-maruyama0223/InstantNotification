//
//  RemindTableViewModel.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/27.
//  
//

import Foundation
import NotificationCenter

protocol TaskModelDelegate: AnyObject {
    func registerTask(record: TaskCellRecord)
}

class TaskModel {
    weak var delegate: TaskModelDelegate?
    var task: TaskCellRecord?

    func registerTask(hour: String, minute: String, task: String) {
        createRecord(hour: hour, minute: minute, task: task)
        guard let record = self.task else { return }
        createNotification(record: record)
        delegate?.registerTask(record: record)
    }

    func deleteNotification(task: TaskCellRecord) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [createNotificationIdentifier(task: task)]
        )
    }

    private func createRecord(hour: String, minute: String, task: String) {
        // TODO:- バリデーション
        func validateTime(hour: String, minute: String) {
        }
        self.task = TaskCellRecord(task: task, hour: hour, minute: minute)
    }

    private func createNotificationIdentifier(task: TaskCellRecord) -> String {
        return task.hour + task.minute + task.task
    }

    private func createNotification(record: TaskCellRecord) {
        var dc = DateComponents()
        dc.hour = Int(record.hour)
        dc.minute = Int(record.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "時間です!"
        content.body = record.task
        content.sound = .default
        let request = UNNotificationRequest(identifier: createNotificationIdentifier(task: record), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

struct TaskCellRecord {
    let task: String
    let hour: String
    let minute: String
}
