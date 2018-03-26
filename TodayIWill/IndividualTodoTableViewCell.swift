//
//  IndividualTodoTableViewCell.swift
//  TodayIWill
//
//  Created by Karthik Nair on 3/21/18.
//  Copyright © 2018 Karthik Nair. All rights reserved.
//

import UIKit
protocol ExpandingTableViewCellDelegate: class {
    func didChangeText(text: String?, cell: IndividualTodoTableViewCell)
}

class IndividualTodoTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var todoTextView: UITextView!
    
    weak var delegate: ExpandingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.didChangeText(text: textView.text, cell: self)
    }
    

}

