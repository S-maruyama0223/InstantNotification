//
//  MainView.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/24.
//  
//

import UIKit

class MainView: UIView, UITableViewDataSource, UITableViewDelegate {

    private var tasks = [String]()
    private let remindTableView = UITableView()
    private let hourTextField = UITextField()
    private let minuteTextField = UITextField()
    private let taskTextField = UITextField()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        remindTableView.translatesAutoresizingMaskIntoConstraints = false
        hourTextField.translatesAutoresizingMaskIntoConstraints = false
        minuteTextField.translatesAutoresizingMaskIntoConstraints = false
        taskTextField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(remindTableView)
        self.addSubview(hourTextField)
        self.addSubview(minuteTextField)
        self.addSubview(taskTextField)

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
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        return cell
    }

}
