//
//  XibView.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/03/02.
//  
//

import UIKit

protocol MainViewDelegate: AnyObject {
    func getRemindTableViewDataSource() -> [TaskCellRecord]
    func deleteRemindTableViewDataSource(at dataSourceIndex: Int)
}

class MainView: UIView, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: MainViewDelegate?
    private var remindTableViewDataSource: [TaskCellRecord] {
        if let ds = delegate?.getRemindTableViewDataSource() {
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tasks = remindTableViewDataSource
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifierからセルが取得できなければ空のセルを返す
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskCell else { return UITableViewCell()}
        cell.setCell(record: remindTableViewDataSource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.deleteRemindTableViewDataSource(at: indexPath.row)
            remindTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension MainView {

}
