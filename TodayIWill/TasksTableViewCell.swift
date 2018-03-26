//
//  TasksTableViewCell.swift
//  TodayIWill
//
//  Created by Karthik Nair on 3/24/18.
//  Copyright © 2018 Karthik Nair. All rights reserved.
//

import UIKit

protocol TasksTableViewCellDelegate {
    func updated(height: CGFloat)
}

class TasksTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTextView: UITextView!
    
    var delegate: TasksTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        taskTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension TasksTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let height = textView.newHeight(withBaseHeight: 50)
        delegate?.updated(height: height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
