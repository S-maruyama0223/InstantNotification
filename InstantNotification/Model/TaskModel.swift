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
    func failureValidation()
    func successValidation()
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


    /// バリデーションメソッド
    /// - Parameters:
    ///   - task: 入力されたタスク
    ///   - hour: 入力されたhour
    ///   - minute:入力されたminute
    func validateTextField(task: String, hour: String, minute: String) {

        // タスクが空でないかの判定
        if task.isEmpty {
            delegate?.failureValidation()
            return
        }

        guard let hourNum = Int(hour), let minuteNum = Int(minute) else {
            // 数値を入力してください。
            delegate?.failureValidation()
            return
        }

        // 時間範囲のバリデーション
        if hourNum   > 23 ||
           minuteNum > 59 {
            delegate?.failureValidation()
            return
        }

        // 文字数のバリデーション
        if hour.count   < 2 ||
           minute.count < 2 {
            delegate?.failureValidation()
            return
        }

        delegate?.successValidation()
    }


    /// 受け取った入力内容をタスク登録するメソッド
    /// - Parameters:
    ///   - dateIndex: 0か1の値
    ///   - hour: 入力されたhour文字列
    ///   - minute: 入力されたminute文字列
    ///   - task: 入力されたtask文字列
    func registerTask(dateIndex: Int, hour: String, minute: String, task: String) {
        let record = createRecord(dateIndex: dateIndex, hour: hour, minute: minute, task: task)
        createNotification(record: record)
        delegate?.registerTask(record: record)
    }



    /// 現状登録されているタスクを端末に保存するメソッド
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


    /// 完了済みのタスクを振り分けるメソッド
    private func checkFinishedTasks() {
        for (index, task) in tasks.enumerated().reversed() {
            if task.date <= Date() {
                finishedTasks.append(tasks.remove(at: index))
            }
        }
    }


    /// 入力されたテキストから一つの登録タスクデータを作成するメソッド
    /// - Parameters:
    ///   - dateIndex: 0か1の値
    ///   - hour: 入力されたhour文字列
    ///   - minute: 入力されたminute文字列
    ///   - task: 入力されたtask文字列
    /// - Returns:TaskCellRecord
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

        func createDate(dateIndex: Int, hour: String, minute: String) -> Date {
            let date: Date
            if dateIndex == 0 {
                // dateIndexが0なら今日
                date = Date()
            } else {
                // dateIndexが0でなければ明日
                date = Date(timeIntervalSinceNow: 60 * 60 * 24)
            }
            // 与えられた時間文字列からDateを作成
            var dc = DateComponents()
            let df = DateFormatter()
            df.dateFormat = "YYYY"
            dc.year = Int(df.string(from: date))
            df.dateFormat = MMDD.MM.toString()
            dc.month = Int(df.string(from: date))
            df.dateFormat = MMDD.dd.toString()
            dc.day = Int(df.string(from: date))
            dc.hour = Int(hour)
            dc.minute = Int(minute)
            guard let createdDate = dc.date else { return Date() }
            return createdDate
        }

        let createdTask = TaskCellRecord(task: task,
                                         date: createDate(dateIndex: dateIndex, hour: hour, minute: minute),
                                         month: createStringDate(format: .MM),
                                         day: createStringDate(format: .dd),
                                         hour: hour,
                                         minute: minute)
        self.tasks.append(createdTask)
        return createdTask
    }


    /// 通知を登録するidを作成するメソッド
    /// - Parameter task: タスク内容
    /// - Returns: 作成したid
    private func createNotificationIdentifier(task: TaskCellRecord) -> String {
        return task.month + task.day + task.hour + task.minute + task.task
    }


    /// 端末に登録してある通知情報を削除するメソッド
    /// - Parameters:
    ///   - isFinished: 完了済みタスクかどうか
    ///   - tasksIndex: タスク配列のインデックス
    func deleteNotification(isFinished: Bool, tasksIndex: Int) {
        if isFinished {
            // 完了済みタスクなら配列から削除するだけ
            finishedTasks.remove(at: tasksIndex)
        } else {
            // 未完了タスクなら通知と配列内レコードを削除
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [createNotificationIdentifier(task: tasks[tasksIndex])]
            )
            tasks.remove(at: tasksIndex)
        }
    }


    /// 通知情報を登録するメソッド
    /// - Parameter record: TaksCellRecord
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
    let date: Date
    let month: String
    let day: String
    let hour: String
    let minute: String
}

enum MMDD: String {
    case MM
    case dd
    func toString() -> String {
        return self.rawValue
    }
}

enum TimeValidateError: Error {
    case success
    case failure(message: String)
}
