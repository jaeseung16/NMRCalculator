//
//  SolutionTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/13/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SolutionTableViewCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
