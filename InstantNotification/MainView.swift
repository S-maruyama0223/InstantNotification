//
//  XibView.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/03/02.
//  
//

import UIKit

class MainView: UIView, UITableViewDelegate, UITableViewDataSource {

    var tasks = [TaskCellRecord]()
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var remindTableView: UITableView!

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
        hourTextField.keyboardType = .numberPad
        minuteTextField.keyboardType = .numberPad
    }

    private func loadNib() {
        let nib = UINib(nibName: "MainView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
        remindTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "taskCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルが取得できなければ何もしない
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskCell else { return UITableViewCell()}
        cell.setCell(record: tasks[indexPath.row])
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
