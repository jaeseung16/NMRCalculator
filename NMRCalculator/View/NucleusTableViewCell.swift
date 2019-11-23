//
//  NucleusTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/16/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

protocol NucleusTableViewCellDelegate: AnyObject {
    func shouldBeginEditing(_ textField: UITextField) -> Bool
    func shouldReturn()
    func didBeginEditing()
    func didEndEditing(_ cell: NucleusTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?)
}

class NucleusTableViewCell: UITableViewCell {
    // Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    
    // Variables
    var sectionLabel: String?
    var textBeforeEditing: String?
    
    weak var delegate: NucleusTableViewCellDelegate?
    
    // MARK:- Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        itemValue.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLabelAndValue(labelText: String?, valueText: String?) {
        itemLabel.text = labelText
        itemValue.text = valueText
    }
}

extension NucleusTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.shouldBeginEditing(textField) ?? false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.shouldReturn()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //activeField = textField
        textBeforeEditing = textField.text
        textField.text = nil
        delegate?.didBeginEditing()
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
