//
//  FourthViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/13/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SolutionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    

    @IBOutlet weak var SolutionTableView: UITableView!
    @IBOutlet weak var ChemName: UITextField!
    
    let menuItems = ["Molecular weight (g/mol)", "Concentration (mM)", "Concentration (wt%)",
                     "Mass of solute (mg)", "Mass (g) or volume (mL) of water"]
    var itemValues: [String]?
    var valueTextField = Array(repeating: UITextField(), count: 5)
    
    var chemCalc = ChemCalc()
    var activeField: UITextField?
    var textbeforeediting: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if chemCalc.set_molecularweight(100.0) == false {
            
        }
        
        if chemCalc.set_amount("solute", gram: 1.0) == false {
            
        }
        
        if chemCalc.set_amount("solvent", gram: 100.0) == false {
            
        }
        
        if chemCalc.update("mol") == false {
            
        }
        
        if chemCalc.update("molL") == false {
            
        }
        
        if chemCalc.update("mass") == false {
            
        }
        
        chemCalc.set_chemicalname("Chemical Name (optional)")
        
        update_textfields()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        SolutionTableView.contentInset = contentInsets
        SolutionTableView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        SolutionTableView.contentInset = contentInsets
        SolutionTableView.scrollIndicatorInsets = contentInsets
    }
    
    
    // MARK: Update the textfields
    
    func update_textfields() {
        
        itemValues = [chemCalc.molecularweight!.format(".5"), (chemCalc.molL!*1_000).format(".4"),(chemCalc.massfraction!*100).format(".4"), (chemCalc.weight!*1_000).format(".5"), chemCalc.amount_h2o!.format(".5")]
        
        for k in 0..<valueTextField.count {
            switch k {
            case 0:
                if let mw = chemCalc.molecularweight {
                    valueTextField[k].text = mw.format(".5")
                }
            case 1:
                if let concent = chemCalc.molL {
                    valueTextField[k].text = (concent*1000.0).format(".4")
                }
            case 2:
                if let concent = chemCalc.massfraction {
                    valueTextField[k].text = (concent*100.0).format(".4")
                }
            case 3:
                if let wt = chemCalc.weight {
                    valueTextField[k].text = (wt*1000.0).format(".5")
                }
            case 4:
                if let wt = chemCalc.amount_h2o {
                    valueTextField[k].text = wt.format(".5")
                }
            default:
                break
            }
        }
        
        ChemName.text = chemCalc.chemicalName
        
    }
    
    // MARK: UITextFieldDelegate
    
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
        if textField == ChemName {
            chemCalc.set_chemicalname(textField.text!)
        } else if let x = Double(textField.text!) {
            switch textField {
            case valueTextField[0]: // Textfield for molecular weight
                if chemCalc.set_molecularweight(x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if chemCalc.set_molecularweight(Double(textbeforeediting!)!) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if chemCalc.update("mol") == false {
                     warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                } else if chemCalc.update("molL") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                }
                
            case valueTextField[1]: // Textfield for concentration in mol
                if chemCalc.set_concentration("molL", number: x/1000.0) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if chemCalc.set_concentration("molL", number: Double(textbeforeediting!)!/1000.0 ) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if chemCalc.update("mol_reverse") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                } else if chemCalc.update("weight") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mg.")
                } else if chemCalc.update("mass") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in wt%.")
                }
                
            case valueTextField[2]: // Textfield for concentration in wt%
                if chemCalc.set_concentration("mass", number: x/100.0) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if chemCalc.set_concentration("mass", number: Double(textbeforeediting!)!/100.0) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if chemCalc.update("weight_reverse") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mg.")
                } else if chemCalc.update("mol") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                } else if chemCalc.update("molL") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                }
                
            case valueTextField[3]: // Textfield for amount of solute
                if chemCalc.set_amount("solute", gram: x/1000.0) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if chemCalc.set_amount("solute", gram: Double(textbeforeediting!)!/1000.0) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if chemCalc.update("mol") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the amount in mol.")
                } else if chemCalc.update("molL") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                } else if chemCalc.update("mass") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in wt%.")
                }
                
            case valueTextField[4]: // Textfield for amount of water
                if chemCalc.set_amount("solvent", gram: x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if chemCalc.set_amount("solvent", gram: Double(textbeforeediting!)!) == false {
                       warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if chemCalc.update("molL") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in mM.")
                } else if chemCalc.update("mass") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the concentration in wt%.")
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
    
    func warnings(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionTableCell", for: indexPath) as! SolutionTableViewCell
        
        cell.itemLabel.text = menuItems[(indexPath as NSIndexPath).row]
        cell.itemValue.text = itemValues![(indexPath as NSIndexPath).row]
        valueTextField[(indexPath as NSIndexPath).row] = cell.itemValue
        
        return cell
    }

}
