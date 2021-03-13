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
    private var task: TaskCellRecord?
    var tasks = [TaskCellRecord]()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveTasks), name: UIApplication.willTerminateNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerTask(hour: String, minute: String, task: String) {
        createRecord(hour: hour, minute: minute, task: task)
        guard let record = self.task else { return }
        createNotification(record: record)
        delegate?.registerTask(record: record)
    }

    func deleteNotification(tasksIndex: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [createNotificationIdentifier(task: tasks[tasksIndex])]
        )
        tasks.remove(at: tasksIndex)
    }

    func loadSavedTasks() -> [TaskCellRecord] {
        do {
            guard let encodedTasks = UserDefaults.standard.data(forKey: "tasks") else {return [TaskCellRecord]() }
            let loadedTasks = try JSONDecoder().decode([TaskCellRecord].self, from: encodedTasks)
            self.tasks.append(contentsOf: loadedTasks)
            return loadedTasks
        } catch {
            // TODO: 空配列を返しエラ〜メッセージを表示
            return [TaskCellRecord]()
        }
    }

    @objc private func saveTasks() {
        do {
            print("saved")
            let encodedTasks = try JSONEncoder().encode(tasks)
            print(tasks)
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
        } catch {
            // TODO: エラー処理 フラグをudに保存して次回起動時にユーザーに知らせる
            print("error")
        }
    }

    private func createRecord(hour: String, minute: String, task: String) {
        // TODO: バリデーション
        func validateTime(hour: String, minute: String) {
        }
        let createdTask = TaskCellRecord(task: task, hour: hour, minute: minute)
        self.task = createdTask
        self.tasks.append(createdTask)
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

// TODO: NDCodingプロトコルに準拠してUserDefaultsに保存可能な構造体にする
struct TaskCellRecord: Codable {
    let task: String
    let hour: String
    let minute: String
}
