//
//  FourthViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/13/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SolutionViewController: UIViewController {
    

    @IBOutlet weak var SolutionTableView: UITableView!
    @IBOutlet weak var ChemName: UITextField!
    
    let menuItems = ["Molecular weight (g/mol)", "Concentration (mM)", "Concentration (wt%)",
                     "Mass of solute (mg)", "Mass (g) or volume (mL) of water"]
    var itemValues = Array(repeating: String(), count: 5)
    var valueTextField = Array(repeating: UITextField(), count: 5)
    
    var chemCalc = ChemCalc()
    var textbeforeediting: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update_textfields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Keyboard
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        SolutionTableView.contentInset = contentInsets
        SolutionTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        SolutionTableView.contentInset = contentInsets
        SolutionTableView.scrollIndicatorInsets = contentInsets
    }
}

// MARK: - Methods custom to SolutionViewController
extension SolutionViewController {
    func update_textfields() {
        updateItemValues()
        
        // copy itemValues into valueTextField
        for k in 0..<valueTextField.count {
            valueTextField[k].text = itemValues[k]
        }
        
        ChemName.text = chemCalc.chemicalName
    }
    
    func updateItemValues() {
        itemValues[0] = chemCalc.molecularWeight.format(".5")
        itemValues[1] = (chemCalc.molConcentration*1_000).format(".4")
        itemValues[2] = (chemCalc.wtConcentration*100).format(".4")
        itemValues[3] = (chemCalc.gramSolute*1_000).format(".5")
        itemValues[4] = chemCalc.amountSolvent.format(".5")
    }
    
    func warnings(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SolutionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionTableCell", for: indexPath) as! SolutionTableViewCell
        
        cell.itemLabel.text = menuItems[(indexPath as NSIndexPath).row]
        cell.itemValue.text = itemValues[(indexPath as NSIndexPath).row]
        valueTextField[(indexPath as NSIndexPath).row] = cell.itemValue
        
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension SolutionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textbeforeediting = textField.text
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if textField == ChemName {
            let _ = chemCalc.setParameter("chemical", to: text)
        } else if let value = Double(text) {
            switch textField {
            case valueTextField[0]: // Textfield for molecular weight
                chemCalc.updateMolecularWeight(to: value, completionHandler: { (error) in
                    if (error != nil) {
                        warnings("Unable to comply", message: error!)
                    }
                })
                
            case valueTextField[1]: // Textfield for concentration in mol
                chemCalc.updateMolConcentration(to: value/1000.0, completionHandler: { (error) in
                    if (error != nil) {
                        warnings("Unable to comply", message: error!)
                    }
                })
                
            case valueTextField[2]: // Textfield for concentration in wt%
                chemCalc.updateWtConcentration(to: value/100.0, completionHandler: { (error) in
                    if (error != nil) {
                        warnings("Unable to comply", message: error!)
                    }
                })
                
            case valueTextField[3]: // Textfield for amount of solute
                chemCalc.updateGramSolute(to: value/1000.0, completionHandler: { (error) in
                    if (error != nil) {
                        warnings("Unable to comply", message: error!)
                    }
                })
                
            case valueTextField[4]: // Textfield for amount of water
                chemCalc.updateAmountSolvent(to: value, completionHandler: { (error) in
                    if (error != nil) {
                        warnings("Unable to comply", message: error!)
                    }
                })
                
            default:
                break
            }
        } else {
            warnings("Unable to comply.", message: "Please enter a positive number.")
            textField.text = textbeforeediting
        }
        
        update_textfields()
    }
}
