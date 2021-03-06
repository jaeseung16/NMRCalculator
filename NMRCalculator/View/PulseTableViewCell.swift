//
//  PulseTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/13/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

protocol PulseTableViewCellDelegate: AnyObject {
    func didEndEditing(_ cell: PulseTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?)
}

class PulseTableViewCell: UITableViewCell {
    // Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    
    // Variables
    var sectionLabel: String?
    var textBeforeEditing: String?
    var fixed = false
    
    weak var delegate: PulseTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemValue.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func update(state: Bool, labelText: String) {
        fixed = !state
        itemLabel.text = labelText
        itemValue.isEnabled = state
        if #available(iOS 13.0, *) {
            itemValue.textColor = state ? .label : .secondaryLabel
            itemLabel.textColor = state ? .label : .secondaryLabel
        } else {
            // Fallback on earlier versions
             itemLabel.textColor = state ? .black : .gray
            itemLabel.textColor = state ? .black : .gray
        }
    }
}

extension PulseTableViewCell: UITextFieldDelegate {
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
