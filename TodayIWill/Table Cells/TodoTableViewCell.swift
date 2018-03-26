//
//  TodoTableViewCell.swift
//  TodayIWill
//
//  Created by Karthik Nair on 3/23/18.
//  Copyright © 2018 Karthik Nair. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
