//
//  ViewController.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/08.
//  
//

import UIKit

class ViewController: UIViewController {

    private var tasks = [String]()

    @IBOutlet weak var remindTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = MainView()
    }

//    @IBAction func buttontap(_ sender: Any) {
//        tasks.append("wow")
//        remindTableView.reloadData()
//    }

}
