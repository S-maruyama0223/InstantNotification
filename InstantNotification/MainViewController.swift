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
        mainView.doneButton.addTarget(self, action: #selector(tapRegisterButton), for: .touchUpInside)
    }

    @objc func tapRegisterButton() {
        taskModel?.createRecord(hour: mainView.hourTextField.text ?? "00",
                                minute: mainView.minuteTextField.text ?? "00",
                                task: mainView.taskTextField.text ?? ""
        )
    }

}

extension ViewController: TaskModelDelegate {
    func registerTask(record: TaskCellRecord) {
        mainView.tasks.append(record)
        print(mainView.tasks.count)
        mainView.remindTableView.reloadData()
    }

}
