//
//  XibView.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/03/02.
//  
//

import UIKit

protocol MainViewDelegate: AnyObject {
    func getRemindTableViewTasks() -> [TaskCellRecord]
    func getRemindTableViewFinishedTasks() -> [TaskCellRecord]
    func deleteRemindTableViewTasks(at dataSourceIndex: Int)
    func deleteRemindTableViewFinishedTasks(at dataSourceIndex: Int)
}

class MainView: UIView, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: MainViewDelegate?
    private var tasks: [TaskCellRecord] {
        if let ds = delegate?.getRemindTableViewTasks() {
            return ds
        }
        return [TaskCellRecord]()
    }
    private var finishedTasks: [TaskCellRecord] {
        if let ds = delegate?.getRemindTableViewFinishedTasks() {
            return ds
        }
        return [TaskCellRecord]()
    }

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var remindTableView: UITableView!
    @IBOutlet weak var dateControl: UISegmentedControl!

    override init(frame: CGRect) {
        super.init(frame: frame)
        mainViewInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        mainViewInit()
    }

    private func mainViewInit() {
        loadNib()
        remindTableView.delegate = self
        remindTableView.dataSource = self
        hourTextField.keyboardType = .numberPad // 時間を入れるテキストフィールドへのキーボード指定
        minuteTextField.keyboardType = .numberPad // 時間を入れるテキストフィールドへのキーボード指定
    }

    private func loadNib() {
        let nib = UINib(nibName: "MainView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
        remindTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "taskCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if finishedTasks.isEmpty {
            return 1
        } else {
            return 2
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "未通知"
        default:
            return "通知済み"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tasks.count
        default:
            return finishedTasks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifierからセルが取得できなければ空のセルを返す
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskCell else { return UITableViewCell()}

        switch indexPath.section {
        case 0:
            cell.setCell(record: tasks[indexPath.row])
        default:
            cell.setCell(record: finishedTasks[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print(remindTableView.numberOfSections)
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                delegate?.deleteRemindTableViewTasks(at: indexPath.row)
            default:
                delegate?.deleteRemindTableViewFinishedTasks(at: indexPath.row)
            }
            if remindTableView.numberOfRows(inSection: indexPath.section) > 1 {
                remindTableView.deleteRows(at: [indexPath], with: .automatic)
                return
            }
            let indexSet = NSMutableIndexSet()
            indexSet.add(indexPath.section)
            remindTableView.deleteSections(indexSet as IndexSet, with: .fade)
        }

    }
}
