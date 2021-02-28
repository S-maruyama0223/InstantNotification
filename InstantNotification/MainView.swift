//
//  MainView.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/24.
//  
//

import UIKit

class MainView: UIView, UITableViewDataSource, UITableViewDelegate {

    lazy var tasks:[TaskCellRecord] = {
        let task = TaskCellRecord(task: "aaa", time: "12:00")
        return [task]
    }()
//    var tasks = [TaskCellRecord]()
    let remindTableView = UITableView()
    let hourTextField = UITextField()
    let minuteTextField = UITextField()
    let taskTextField = UITextField()
    let registerButton = UIButton()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        remindTableView.delegate = self
        remindTableView.dataSource = self
        remindTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        remindTableView.translatesAutoresizingMaskIntoConstraints = false
        hourTextField.translatesAutoresizingMaskIntoConstraints = false
        minuteTextField.translatesAutoresizingMaskIntoConstraints = false
        taskTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(remindTableView)
        self.addSubview(hourTextField)
        self.addSubview(minuteTextField)
        self.addSubview(taskTextField)
        self.addSubview(registerButton)

        self.backgroundColor = UIColor(red: 0, green: 255, blue: 200, alpha: 1)
        // hourテキストフィールドのautolayout
        hourTextField.backgroundColor = .white
        hourTextField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        hourTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        hourTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -50).isActive = true
        hourTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -150).isActive = true

        // minuteテキストフィールドのautolayout
        minuteTextField.backgroundColor = .white
        minuteTextField.frame = CGRect(x: 200, y: 200, width: 80, height: 35)
        minuteTextField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        minuteTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        minuteTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 50).isActive = true
        minuteTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -150).isActive = true

        // taskテキストフィールドのautolayout
        taskTextField.backgroundColor = .white
        taskTextField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        taskTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        taskTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        taskTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100).isActive = true

        // テーブルビューのautolayout
        remindTableView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        remindTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        remindTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        remindTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        remindTableView.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

        // registerボタンのautolayout
        registerButton.leadingAnchor.constraint(equalTo: taskTextField.trailingAnchor, constant: 10).isActive = true
        registerButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        registerButton.centerYAnchor.constraint(equalTo: taskTextField.centerYAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        registerButton.setTitle("登録", for: .normal)
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.backgroundColor = .white
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskCell else { return UITableViewCell()}
        cell.taskLabel.text = tasks[indexPath.row].task
        cell.timeLabel.text = tasks[indexPath.row].time
        return cell
    }

}
