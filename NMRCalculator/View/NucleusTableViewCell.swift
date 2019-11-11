//
//  NucleusTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/16/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class NucleusTableViewCell: UITableViewCell {
    // Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    
    // MARK:- Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLabelAndValue(labelText: String?, valueText: String?) {
        itemLabel.text = labelText
        itemValue.text = valueText
    }
}
