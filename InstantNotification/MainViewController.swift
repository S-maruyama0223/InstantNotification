//
//  ViewController.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/08.
//  
//

import UIKit

class ViewController: UIViewController {

    private(set) lazy var mainView: MainView = MainView()
    private var taskModel: TaskModel? {
        didSet {
            registerModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = mainView
        taskModel = TaskModel()
        taskModel?.delegate = self
    }

    private func registerModel() {
        mainView.doneButton.addTarget(self, action: #selector(tapDoneButton), for: .touchUpInside)
    }

    /// Doneボタンが押された時にモデルにテキストフィールドの値を渡しレコードを作成する
    @objc private func tapDoneButton() {
        taskModel?.createRecord(hour: mainView.hourTextField.text ?? "00",
                                minute: mainView.minuteTextField.text ?? "00",
                                task: mainView.taskTextField.text ?? ""
        )
    }

}

extension ViewController: TaskModelDelegate {

    /// タスクを登録してビューをに反映する
    /// - Parameter record: TaskCellRecord タスク情報
    func registerTask(record: TaskCellRecord) {
        mainView.tasks.append(record)
        mainView.remindTableView.reloadData()
    }

}
