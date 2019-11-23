//
//  SolutionTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/13/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

protocol SolutionTableViewCellDelegate: AnyObject {
    func didEndEditing(_ cell: SolutionTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?)
}

class SolutionTableViewCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    
    // Variables
    var sectionLabel: String?
    var textBeforeEditing: String?
    
    weak var delegate: SolutionTableViewCellDelegate?
    
    // MARK:- Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        itemValue.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension SolutionTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //activeField = textField
        textBeforeEditing = textField.text
        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // activeField = nil
        
        guard let value = Double(textField.text!) else {
            textField.text = textBeforeEditing
            delegate?.didEndEditing(self, for: itemLabel, newValue: nil, error: "The input was not a number.")
            return
        }
        
        delegate?.didEndEditing(self, for: itemLabel, newValue: value, error: nil)
    }
}
