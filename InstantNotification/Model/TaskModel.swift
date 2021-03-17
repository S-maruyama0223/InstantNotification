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
    private var task: TaskCellRecord? {
        didSet {
            // 二回目以降の代入を不可とする
            if let ov = oldValue {
                task = ov
                print("task can not assign a new value again.")
            }
        }
    }
    var tasks = [TaskCellRecord]()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveTasks), name: UIApplication.willTerminateNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerTask(dateIndex: Int, hour: String, minute: String, task: String) {
        createRecord(dateIndex: dateIndex, hour: hour, minute: minute, task: task)
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
            // TODO: 空配列を返しエラーメッセージを表示
            return [TaskCellRecord]()
        }
    }

    @objc private func saveTasks() {
        do {
            let encodedTasks = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
        } catch {
            // TODO: エラー処理 フラグをudに保存して次回起動時にユーザーに知らせる
            print("error")
        }
    }

//    private func createDateFromString(stringDate: String) -> Date {
//        let df = DateFormatter()
//        df.dateFormat = DATE_FORMAT
//        return df.date(from: stringDate) ?? Date()
//    }

    private func createRecord(dateIndex: Int, hour: String, minute: String, task: String) {
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
        self.task = createdTask
        self.tasks.append(createdTask)
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
