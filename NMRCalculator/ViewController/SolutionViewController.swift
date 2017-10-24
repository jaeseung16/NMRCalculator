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
    var activeField: UITextField?
    var textbeforeediting: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        /*let _ = chemCalc.set_molecularweight(100.0)
        let _ = chemCalc.set_amount("solute", gram: 1.0)
        let _ = chemCalc.set_amount("solvent", gram: 100.0)
        let _ = chemCalc.update("mol")
        let _ = chemCalc.update("molL")
        let _ = chemCalc.update("mass")
        
        chemCalc.set_chemicalname("Chemical Name (optional)")*/
        
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
        itemValues = [chemCalc.molecularWeight.format(".5"), (chemCalc.molConcentration*1_000).format(".4"),(chemCalc.wtConcentration*100).format(".4"), (chemCalc.gramSolute*1_000).format(".5"), chemCalc.amountSolvent.format(".5")]
        
        for k in 0..<valueTextField.count {
            
            switch k {
            case 0:
                itemValues[k] = chemCalc.molecularWeight.format(".5")
            case 1:
                itemValues[k] = (chemCalc.molConcentration*1_000).format(".4")
            case 2:
                itemValues[k] = (chemCalc.wtConcentration*100).format(".4")
            case 3:
                itemValues[k] = (chemCalc.gramSolute*1_000).format(".5")
            case 4:
                itemValues[k] = chemCalc.amountSolvent.format(".5")
            default:
                break
            }
            
            valueTextField[k].text = itemValues[k]
        }
        
        ChemName.text = chemCalc.chemicalName
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
        activeField = textField
        textbeforeediting = textField.text
        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if textField == ChemName {
            let _ = chemCalc.setParameter("chemical", to: text)
        } else if let value = Double(text) {
            switch textField {
            case valueTextField[0]: // Textfield for molecular weight
                guard chemCalc.setParameter("molecularWeight", to: Double(value)) else {
                    guard chemCalc.setParameter("molecularWeight", to: textbeforeediting! ) else {
                        warnings("Unable to comply.", message: "The value is out of range.")
                        break
                    }
                    break
                }
                
                guard chemCalc.updateParameter("molSolute") else {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                    break
                }
                
                guard chemCalc.updateParameter("molConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                    break
                }
                
            case valueTextField[1]: // Textfield for concentration in mol
                guard chemCalc.setParameter("molConcentration", to: value/1000.0) else {
                    guard chemCalc.setParameter("molConcentration", to: Double(textbeforeediting!)!/1000.0) else {
                        warnings("Unable to comply.", message: "The value is out of range.")
                        break
                    }
                    break
                }
                
                guard chemCalc.updateParameter("molSolute", flag: false) else {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                    break
                }
                
                guard chemCalc.updateParameter("gramSolute") else {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mg.")
                    break
                }
                
                guard chemCalc.updateParameter("wtConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in wt%.")
                    break
                }
                
            case valueTextField[2]: // Textfield for concentration in wt%
                guard chemCalc.setParameter("wtConcentration", to: value/100.0) else {
                    guard chemCalc.setParameter("wtConcentration", to: Double(textbeforeediting!)!/100.0) else {
                        warnings("Unable to comply.", message: "The value is out of range.")
                        break
                    }
                    break
                }
                
                guard chemCalc.updateParameter("gramSolute", flag: false) else {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mg.")
                    break
                }
                
                guard chemCalc.updateParameter("molSolute") else {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                    break
                }
                
                guard chemCalc.updateParameter("molConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                    break
                }
                
            case valueTextField[3]: // Textfield for amount of solute
                guard chemCalc.setParameter("gramSolute", to: value/1000.0) else {
                    guard chemCalc.setParameter("gramSolute", to: Double(textbeforeediting!)!/1000.0) else {
                        warnings("Unable to comply.", message: "The value is out of range.")
                        break
                    }
                    break
                }
                
                guard chemCalc.updateParameter("molSolute") else {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                    break
                }
                
                guard chemCalc.updateParameter("molConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                    break
                }
                
                guard chemCalc.updateParameter("wtConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in wt%.")
                    break
                }
                
            case valueTextField[4]: // Textfield for amount of water
                guard chemCalc.setParameter("amountSolvent", to: value) else {
                    guard chemCalc.setParameter("amountSolvent", to: Double(textbeforeediting!)!) else {
                        warnings("Unable to comply.", message: "The value is out of range.")
                        break
                    }
                    break
                }
                
                guard chemCalc.updateParameter("molConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                    break
                }
                
                guard chemCalc.updateParameter("wtConcentration") else {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in wt%.")
                    break
                }
                
            default:
                break
            }
        } else {
            textField.text = textbeforeediting
        }
        
        update_textfields()
        
        activeField = nil
    }
}
