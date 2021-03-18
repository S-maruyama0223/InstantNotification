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
    var tasks = [TaskCellRecord]()

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveTasks),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        do {
            if let encodedTasks = UserDefaults.standard.data(forKey: "tasks") {
                let loadedTasks = try JSONDecoder().decode([TaskCellRecord].self, from: encodedTasks)
                self.tasks.append(contentsOf: loadedTasks)
            }
        } catch {
            // TODO: エラーメッセージをViewに表示
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerTask(dateIndex: Int, hour: String, minute: String, task: String) {
        let record = createRecord(dateIndex: dateIndex, hour: hour, minute: minute, task: task)
        createNotification(record: record)
        delegate?.registerTask(record: record)
    }

    func deleteNotification(tasksIndex: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [createNotificationIdentifier(task: tasks[tasksIndex])]
        )
        tasks.remove(at: tasksIndex)
    }

    @objc private func saveTasks() {
        do {
            let encodedTasks = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
            print("saved\(tasks)")
        } catch {
            // TODO: エラー処理 フラグをudに保存して次回起動時にユーザーに知らせる
            print("error")
        }
    }

    private func createRecord(dateIndex: Int, hour: String, minute: String, task: String) -> TaskCellRecord {
        /// 日付パラメータから日付を判断して指定のフォーマットで返す
        func createStringDate(format: MMDD) -> String {
            let df = DateFormatter()
            df.dateFormat = format.rawValue
            if dateIndex == 0 {
                return df.string(for: Date())!
            } else {
                return df.string(for: Date(timeIntervalSinceNow: 60 * 60 * 24))!
            }
        }
        // TODO: バリデーション　監視メソッド内に移すかも
        func validateTime(hour: String, minute: String) {
        }

        let createdTask = TaskCellRecord(task: task,
                                         month: createStringDate(format: .MM),
                                         day: createStringDate(format: .dd),
                                         hour: hour,
                                         minute: minute)
        self.tasks.append(createdTask)
        return createdTask
    }

    private func createNotificationIdentifier(task: TaskCellRecord) -> String {
        return task.month + task.day + task.hour + task.minute + task.task
    }

    private func createNotification(record: TaskCellRecord) {
        var dc = DateComponents()
        dc.month = Int(record.month)
        dc.day = Int(record.day)
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

struct TaskCellRecord: Codable {
    let task: String
    let month: String
    let day: String
    let hour: String
    let minute: String
}

enum MMDD: String {
    case MM
    case dd
}

enum DayPattern: Int {
    case today
    case tommorow
}
