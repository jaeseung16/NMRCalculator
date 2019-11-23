//
//  FourthViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/13/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SolutionViewController: UIViewController {
    // MARK: Properties
    // Outlets
    @IBOutlet weak var solutionTableView: UITableView!
    @IBOutlet weak var chemicalNameTextField: UITextField!
    
    // Constants
    enum Menu: Int {
        case molecularWeight, concentration, concentrationWt, mass, volume
    }
    
    let menuItems: [Menu: String] = [.molecularWeight: "Molecular weight (g/mol)",
                                     .concentration: "Concentration (mM)",
                                     .concentrationWt: "Concentration (wt%)",
                                     .mass: "Mass of solute (mg)",
                                     .volume: "Mass (g) or volume (mL) of water"]
    
    var itemValues: [Menu: String] = [.molecularWeight: String(),
                                      .concentration: String(),
                                      .concentrationWt: String(),
                                      .mass: String(),
                                      .volume: String()]
    
    var chemCalc = ChemCalc()
    var textbeforeediting: String?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readOrSetUserDefaults()
        updateTextFields()
    }
    
    func readOrSetUserDefaults() {
        readOrSetChemName()
        readOrSetMolecularWeight()
        readOrSetAmountSolvent()
        readOrSetGramSolute()
    }
    
    func readOrSetChemName() {
        if let name = UserDefaults.standard.object(forKey: "ChemName") as? String {
            chemicalNameTextField.text = name
        } else {
            UserDefaults.standard.set(chemicalNameTextField.text!, forKey: "ChemName")
        }
    }
    
    func readOrSetMolecularWeight() {
        if let molecularWeight = UserDefaults.standard.object(forKey: "MolecularWeight") as? Double {
            chemCalc.molecularWeight = molecularWeight
        } else {
            UserDefaults.standard.set(chemCalc.molecularWeight, forKey: "MolecularWeight")
        }
    }
    
    func readOrSetAmountSolvent() {
        if let amountSolvent = UserDefaults.standard.object(forKey: "AmountSolvent") as? Double {
            chemCalc.amountSolvent = amountSolvent
        } else {
             UserDefaults.standard.set(chemCalc.amountSolvent, forKey: "AmountSolvent")
        }
    }
    
    func readOrSetGramSolute() {
        if let gramSolute = UserDefaults.standard.object(forKey: "GramSolute") as? Double {
            chemCalc.updateGramSolute(to: gramSolute) { (error) in
                if (error != nil) {
                    showWarning("Unable to comply", message: error!)
                }
            }
        } else {
            UserDefaults.standard.set(chemCalc.gramSolute, forKey: "GramSolute")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Keyboard
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        solutionTableView.contentInset = contentInsets
        solutionTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        solutionTableView.contentInset = contentInsets
        solutionTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: IBActions
    @IBAction func searchWebButtonDown(_ sender: UIBarButtonItem) {
        guard let url = buildURL() else {
            showWarning("Unable to comply", message: "Cannot perform a search. Check the name of the chemical.")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    func buildURL() -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "www.google.com"
        component.path = "/search"
        
        component.queryItems = [URLQueryItem]()
        component.queryItems!.append(URLQueryItem(name: "oe", value: "utf-8"))
        component.queryItems!.append(URLQueryItem(name: "ie", value: "utf-8"))
        component.queryItems!.append(URLQueryItem(name: "q", value: chemicalNameTextField.text!))
        
        return component.url
    }
}

// MARK: - Methods custom to SolutionViewController
extension SolutionViewController {
    func updateTextFields() {
        updateItemValues()
        
        chemicalNameTextField.text = chemCalc.chemicalName
        
        UserDefaults.standard.set(chemicalNameTextField.text!, forKey: "ChemName")
        
        UserDefaults.standard.set(chemCalc.molecularWeight, forKey: "MolecularWeight")
        UserDefaults.standard.set(chemCalc.amountSolvent, forKey: "AmountSolvent")
        UserDefaults.standard.set(chemCalc.gramSolute, forKey: "GramSolute")
        
        solutionTableView.reloadData()
    }
    
    func updateItemValues() {
        itemValues[.molecularWeight] = chemCalc.molecularWeight.format(".5")
        itemValues[.concentration] = (chemCalc.molConcentration*1_000).format(".4")
        itemValues[.concentrationWt] = (chemCalc.wtConcentration*100).format(".4")
        itemValues[.mass] = (chemCalc.gramSolute*1_000).format(".5")
        itemValues[.volume] = chemCalc.amountSolvent.format(".5")
    }
    
    func showWarning(_ title: String, message: String) {
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
        
        let menu = Menu(rawValue: indexPath.row)!
        
        cell.itemLabel.text = menuItems[menu]!
        cell.itemValue.text = itemValues[menu]!
        cell.delegate = self
        
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

        if textField == chemicalNameTextField {
            let _ = chemCalc.set(parameter: .chemical, to: text)
            UserDefaults.standard.set(chemicalNameTextField.text!, forKey: "ChemName")
            updateTextFields()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// MARK: - SolutionTableViewCellDelegate
extension SolutionViewController: SolutionTableViewCellDelegate {
    func didEndEditing(_ cell: SolutionTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?) {
        func showWarningIfErrorOccured(_ error: String?) {
            if (error != nil) {
                showWarning("Unable to comply", message: error!)
            }
        }
        
        guard error == nil else {
            showWarning("Unable to comply.", message: "The input was not a number.")
            return
        }
        
        guard let newValue = newValue else {
            return
        }
        
        switch cellLabel.text! {
        case menuItems[.molecularWeight]:
            chemCalc.updateMolecularWeight(to: newValue, completionHandler: showWarningIfErrorOccured)

        case menuItems[.concentration]:
            chemCalc.updateMolConcentration(to: newValue/1000.0, completionHandler: showWarningIfErrorOccured)
            
        case menuItems[.concentrationWt]:
            chemCalc.updateWtConcentration(to: newValue/100.0, completionHandler: showWarningIfErrorOccured)
            
        case menuItems[.mass]:
            chemCalc.updateGramSolute(to: newValue/1000.0, completionHandler: showWarningIfErrorOccured)
            
        case menuItems[.volume]:
            chemCalc.updateAmountSolvent(to: newValue, completionHandler: showWarningIfErrorOccured)
            
        default:
            showWarning("Unable to comply.", message: "The value is out of range.")
            return
        }
        
        updateTextFields()
    }
}
