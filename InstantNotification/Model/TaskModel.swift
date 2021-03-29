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
    static let taskModel = TaskModel()
    weak var delegate: TaskModelDelegate?
    private(set) var tasks = [TaskCellRecord]()
    private(set) var finishedTasks = [TaskCellRecord]()

    // 外部からのインスタンス化を禁止しシングルトンとする
    private init() {
        // UserDefaults内のタスクの読み込み
        do {
            if let loadedTasks = UserDefaults.standard.data(forKey: "tasks") {
                   let decodedTasks = try JSONDecoder().decode([TaskCellRecord].self, from: loadedTasks)
                   self.tasks.append(contentsOf: decodedTasks)
            }
            if let loadedFinishedTasks = UserDefaults.standard.data(forKey: "finishedTasks") {
                   let decordedFinishedTasks = try JSONDecoder().decode([TaskCellRecord].self, from: loadedFinishedTasks)
                   self.finishedTasks.append(contentsOf: decordedFinishedTasks)
            }
        } catch {
            // TODO: エラーメッセージをViewに表示
        }
        self.checkFinishedTasks()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerTask(dateIndex: Int, hour: String, minute: String, task: String) {
        let record = createRecord(dateIndex: dateIndex, hour: hour, minute: minute, task: task)
        createNotification(record: record)
        delegate?.registerTask(record: record)
    }

    func saveTasks() {
        do {
            let encodedTasks = try JSONEncoder().encode(tasks)
            let encodedFinishedTasks = try JSONEncoder().encode(finishedTasks)
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
            UserDefaults.standard.set(encodedFinishedTasks, forKey: "finishedTasks")
        } catch {
            // TODO: エラー処理 フラグをudに保存して次回起動時にユーザーに知らせる
            print("error")
        }
    }

    private func checkFinishedTasks() {
        let df = DateFormatter()
        df.dateFormat = "MMddHHmm"
        let now = Int(df.string(from: Date()))!
        for (i, _) in tasks.enumerated().reversed() {
            let task = tasks[i]
            if Int("\(task.month)\(task.day)\(task.hour)\(task.minute)")! <= now {
                finishedTasks.append(tasks.remove(at: i))
            }
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

    func deleteNotification(isFinished: Bool, tasksIndex: Int) {
        if isFinished {
            finishedTasks.remove(at: tasksIndex)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [createNotificationIdentifier(task: tasks[tasksIndex])]
            )
            tasks.remove(at: tasksIndex)
        }
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
