//
//  XibView.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/03/02.
//  
//

import UIKit

class MainView: UIView, UITableViewDelegate, UITableViewDataSource {

    var finishedTasks = [TaskCellRecord(task: "終わり1", time: "12:00"), TaskCellRecord(task: "終わり2", time: "13:00")] {
        didSet {
            remindTableView.reloadData()
        }
    }
    var tasks = [TaskCellRecord]() {
        didSet {
            remindTableView.reloadData()
        }
    }
    var isDisplayFinisedTasks = true {
        didSet {
            remindTableView.reloadData()
        }
    }
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var remindTableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        remindTableView.delegate = self
        remindTableView.dataSource = self
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
        remindTableView.delegate = self
        remindTableView.dataSource = self
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
        // 完了表示フラグがオフならセクション一つ(完了)のみ
        if isDisplayFinisedTasks == false {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "完了"
        default:
            return "未完了"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tasks.count
        } else {
            return finishedTasks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // カスタムセルが取得出来なければUITableViewセルを返す
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskCell else { return UITableViewCell()}
        if indexPath.section == 0 {
            cell.setCell(record: tasks[indexPath.row])
        } else {
            cell.setCell(record: finishedTasks[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            remindTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
