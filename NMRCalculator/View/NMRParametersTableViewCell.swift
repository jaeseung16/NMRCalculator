//
//  NMRParametersTableViewCell.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/12/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

protocol NMRParametersTableViewCellDelegate: AnyObject {
    func shouldBeginEditing(_ textField: UITextField) -> Bool
    func shouldReturn()
    func didBeginEditing(_ textField: UITextField)
    func didEndEditing(_ cell: NMRParametersTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?)
}

class NMRParametersTableViewCell: UITableViewCell {
    // Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    
    // Variables
    var sectionLabel: String?
    var textBeforeEditing: String?
    
    weak var delegate: NMRParametersTableViewCellDelegate?
    
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

extension NMRParametersTableViewCell: UITextFieldDelegate {
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
        delegate?.didBeginEditing(textField)
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
