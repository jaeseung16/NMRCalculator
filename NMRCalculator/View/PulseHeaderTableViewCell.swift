//
//  PulseHeaderTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/15/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class PulseHeaderTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    @IBOutlet weak var pulseHeaderLabel: UILabel!
    
    // MARK:- Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
