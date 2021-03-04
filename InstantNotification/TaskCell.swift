//
//  TaskCell.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/27.
//  
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak private var taskLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCell(record: TaskCellRecord) {
        self.taskLabel.text = record.task
        self.timeLabel.text = record.time
    }
}
