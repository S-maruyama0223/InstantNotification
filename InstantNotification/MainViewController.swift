//
//  ViewController.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/08.
//  
//

/*
* やることリスト
* カスタムアラート音
* バリデーション
* キーボードツールバー
* テキストフィールド入力値制御
* 過去履歴作成
* タスク取り消し機能 ok
* タスク保存
* 完了タスク自動削除
* タスク通知後完了化
*
*
*/

import UIKit
import UserNotifications

class ViewController: UIViewController {

    private(set) lazy var mainView: MainView = MainView()
    private var taskModel: TaskModel? {
        didSet {
            registerModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        taskModel = TaskModel()
        self.view = mainView
        taskModel?.delegate = self
        mainView.delegate = self
    }

    private func registerModel() {
        mainView.doneButton.addTarget(self, action: #selector(tapDoneButton), for: .touchUpInside)
    }

    /// Doneボタンが押された時にモデルにテキストフィールドの値を渡しレコードを作成する
    @objc private func tapDoneButton() {
        taskModel?.registerTask(hour: mainView.hourTextField.text ?? "00",
                                minute: mainView.minuteTextField.text ?? "00",
                                task: mainView.taskTextField.text ?? ""
        )
    }

}

extension ViewController: TaskModelDelegate {

    /// タスクを登録してビューに反映する
    /// - Parameter record: TaskCellRecord タスク情報
    func registerTask(record: TaskCellRecord) {
        mainView.remindTableView.reloadData()
    }
}

extension ViewController: MainViewDelegate {
    /// viewからタスクが削除された通知をmodelに仲介する
    /// - Parameter task: 削除されたタスク
    func deleteRemindTableViewDataSource(at dataSourceIndex: Int) {
        taskModel?.deleteNotification(tasksIndex: dataSourceIndex)
    }

    func getRemindTableViewDataSource() -> [TaskCellRecord] {
        return taskModel?.tasks ?? [TaskCellRecord]()
    }
}
