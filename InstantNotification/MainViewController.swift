//
//  ViewController.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/08.
//  
//

/*
* やることリスト
* オートレイアウト
* カスタムアラート音
* バリデーション ok
* キーボードツールバー
* テキストフィールド入力値制御 ok
* タスク取り消し機能 ok
* タスク保存 ok
* 完了タスク自動削除/過去履歴作成  ok
* タスク通知後完了化 可能か？
* アクティブな通知を５こまでに制限
* タスク追加時に重複のチェック
* 構造体のStringプロパティを消せないか検討
* ソート
* メッセージ表示
*
*
*
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
        taskModel = TaskModel.taskModel
        self.view = mainView
        taskModel?.delegate = self
        mainView.delegate = self
    }


    private func registerModel() {
        mainView.taskTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        mainView.hourTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        mainView.minuteTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        mainView.doneButton.addTarget(self, action: #selector(tapDoneButton), for: .touchUpInside)
    }

    /// Doneボタンが押された時にモデルにテキストフィールドの値を渡しレコードを作成する
    @objc private func tapDoneButton() {
        taskModel?.registerTask(dateIndex: mainView.dateControl.selectedSegmentIndex,
                                hour: mainView.hourTextField.text ?? "00",
                                minute: mainView.minuteTextField.text ?? "00",
                                task: mainView.taskTextField.text ?? ""
        )
    }

    @objc private func textFieldEditingChanged(sender: UITextField) {
        if sender.text?.count ?? 0 > 2 { // 現状の言語仕様ではフォースアンラップでも安全だがcountは0をデフォルトとする
            sender.text = sender.text?.prefix(2).description
            return
        }
        // TODO: 両方空の時にデフォルト時間を挿入
        taskModel?.validateTextField(task: mainView.taskTextField.text ?? "",
                                     hour: mainView.hourTextField.text ?? "",
                                     minute: mainView.minuteTextField.text ?? ""
        )
    }
}

extension ViewController: TaskModelDelegate {

    /// タスクを登録してビューに反映する
    /// - Parameter record: TaskCellRecord タスク情報
    func registerTask(record: TaskCellRecord) {
        mainView.remindTableView.reloadData()
    }

    func failureValidation() {
        mainView.doneButton.isEnabled = false
    }
    func successValidation() {
        mainView.doneButton.isEnabled = true
    }
}

extension ViewController: MainViewDelegate {
    /// viewからタスクが削除された通知をmodelに仲介する
    /// - Parameter at: 削除するセルの行数
    func deleteRemindTableViewTasks(at dataSourceIndex: Int) {
        taskModel?.deleteNotification(isFinished: false, tasksIndex: dataSourceIndex)
    }

    func deleteRemindTableViewFinishedTasks(at dataSourceIndex: Int) {
        taskModel?.deleteNotification(isFinished: true, tasksIndex: dataSourceIndex)
    }

    /// TableViewから要求されたtasksデータソースを返す
    /// - Returns: [TaskCellRecord]
    func getRemindTableViewTasks() -> [TaskCellRecord] {
        return taskModel?.tasks ?? [TaskCellRecord]()
    }

    /// TableViewから要求されたfinishedTasksデータソースを返す
    /// - Returns: [TaskCellRecord]
    func getRemindTableViewFinishedTasks() -> [TaskCellRecord] {
        return taskModel?.finishedTasks ?? [TaskCellRecord]()
    }
}
