//
//  FirstViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/8/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)g", self)
    }
}

class NucleusViewController: UIViewController {
    // MARK: Properties
    // Outlets
    @IBOutlet weak var NucleusTableView: UITableView!
    @IBOutlet weak var nucleusPicker: UIPickerView!
    @IBOutlet weak var nucleusName: UILabel!
    
    enum Menu: Int {
        case larmorFrequency
        case externalMagneticField
        case protonLarmorFrequency
        case electronLarmorFrequency
    }
    
    // Constants
    let menuItems: [Menu: String] = [.larmorFrequency: "Larmor Frequency (MHz)",
                                     .externalMagneticField: "External Magnetic Field (Tesla)",
                                     .protonLarmorFrequency: "Proton's Larmor Frequency (MHz)",
                                     .electronLarmorFrequency:"Electron's Larmor Frequency (GHz)"]
    
    let numberofColumn = 1
    
    // Variables
    var itemValues: [Menu: String] = [.larmorFrequency: "",
                                     .externalMagneticField: "",
                                     .protonLarmorFrequency: "",
                                     .electronLarmorFrequency: ""]
    
    // TODO: Try this in a different way
    var valueTextField = Array(repeating: UITextField(), count: 4)
    
    var periodicTable: NMRPeriodicTable!
    var nucleus: NMRNucleus?
    var nmrCalc: NMRCalc?
    
    var activeField: UITextField?
    var textbeforeediting: String?
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tabBarController = self.tabBarController as? NMRCalcTabBarController else {
            return
        }
        
        periodicTable = tabBarController.periodicTable
        initializeView()
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
    
    // MARK:- Initialize the nuclues table
    func initializeView() {
        selectNucleus()
        setExternalField()
        updateTextFields()
    }
    
    func selectNucleus() {
        let identifier = UserDefaults.standard.string(forKey: "Nucleus") ?? "1H"
        let row = periodicTable.nucleiDictionary[identifier] ?? 0
        nucleus = periodicTable.nuclei[row]
        nmrCalc = NMRCalc(nucleus: nucleus!)
        nucleusPicker.selectRow(row, inComponent: numberofColumn - 1, animated: true)
    }
    
    func setExternalField() {
        let externalField = UserDefaults.standard.string(forKey: "B0") ?? "1.0"
        nmrCalc!.updateLarmor("field", to: Double(externalField)!) { error in
            if (error != nil) {
                self.warnings("Unable to comply.", message: error!)
            }
        }
    }
    
    // MARK:- Update textfields
    func updateTextFields() {
        updateItemValues()
        
        if let _ = nmrCalc?.larmorNMR {
            for k in 0..<valueTextField.count {
                valueTextField[k].text = itemValues[Menu(rawValue: k)!]
            }
        }
        
        if let nucleus = nmrCalc?.nucleus {
            nucleusName.text = nucleus.nameNucleus
        }
        
        UserDefaults.standard.setValue(nucleus?.identifier, forKey: "Nucleus")
    }
    
    func updateItemValues() {
        guard let itemValuesDict = nmrCalc?.getLarmor() else {
            return
        }
    
        itemValues[.larmorFrequency] = itemValuesDict[.larmor]!.format(".4")
        itemValues[.externalMagneticField] = itemValuesDict[.field]!.format(".4")
        itemValues[.protonLarmorFrequency] = itemValuesDict[.proton]!.format(".4")
        itemValues[.electronLarmorFrequency] = itemValuesDict[.electron]!.format(".4")
        
        UserDefaults.standard.set(itemValues[.externalMagneticField], forKey: "B0")
    }
    
    // MARK:- Methods for Keyboard
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let pickerSize = nucleusPicker.frame
        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: kbSize.height - pickerSize.height, right: 0.0)
        NucleusTableView.contentInset = contentInsets
        NucleusTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        NucleusTableView.contentInset = contentInsets
        NucleusTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: IBActions
    @IBAction func searchWebButtonDown(_ sender: UIBarButtonItem) {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "www.google.com"
        component.path = "/search"
        component.queryItems = [URLQueryItem]()
        
        component.queryItems!.append( URLQueryItem(name: "oe", value: "utf-8") )
        component.queryItems!.append( URLQueryItem(name: "ie", value: "utf-8") )
        component.queryItems!.append( URLQueryItem(name: "q", value: nucleusName.text!) )
        
        guard let url = component.url else {
            warnings("Unable to comply", message: "Cannot perform a search. Check the name of the chemical.")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: Warning messages
    func warnings(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension NucleusViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return periodicTable.nuclei.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 90.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 270.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let nucleusView = view as? NucleusView else {
            return NucleusView(frame: CGRect(x: 0, y: 0, width: 270.0, height: 90.0), nucleus: periodicTable.nuclei[row])
        }
        
        return nucleusView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nucleus = periodicTable.nuclei[row]
        nmrCalc!.nucleus = nucleus!
        nmrCalc!.larmorNMR = NMRLarmor(nucleus: nucleus!) // Why do I need this?
        
        guard let value = Double(valueTextField[1].text!) else {
            warnings("Unable to comply.", message: "The input should be a number.")
            return
        }
        
        nmrCalc!.updateLarmor("field", to: value) { error in
            if (error != nil) {
                self.warnings("Unable to comply.", message: error!)
            }
        }
        
        updateTextFields()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NucleusViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NucleusTableCell", for: indexPath) as! NucleusTableViewCell
        let row = indexPath.row
        
        cell.itemLabel.text = menuItems[Menu(rawValue: row)!]
        cell.itemValue.text = itemValues[Menu(rawValue: row)!]
        valueTextField[row] = cell.itemValue
        
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension NucleusViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let selected = nucleusPicker.selectedRow(inComponent: numberofColumn-1)

        if selected == -1 {
            warnings("Unable to comply.", message: "Select a nucleus.")
            return false
        } else {
            nucleusPicker.selectRow(selected, inComponent: numberofColumn-1, animated: true)
            nucleus = periodicTable.nuclei[selected]
            nmrCalc!.nucleus = nucleus
            nucleusName.text = nmrCalc!.nucleus!.nameNucleus
            nmrCalc!.larmorNMR = NMRLarmor(nucleus: nucleus!) 
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nucleusPicker.isUserInteractionEnabled = true
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nucleusPicker.isUserInteractionEnabled = false
        
        activeField = textField
        textbeforeediting = textField.text
        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
        
        guard let x = Double(textField.text!) else {
            warnings("Unable to comply.", message: "The input was not a number.")
            textField.text = textbeforeediting
            return
        }
        
        var firstParameter = ""
        let value = x
        
        switch textField {
        case valueTextField[0]:
            firstParameter = "larmor"
        case valueTextField[1]:
            firstParameter = "field"
        case valueTextField[2]:
            firstParameter = "proton"
        case valueTextField[3]:
            firstParameter = "electron"
        default:
            warnings("Unable to comply.", message: "The value is out of range.")
            textField.text = textbeforeediting
            return
        }
        
        nmrCalc!.updateLarmor(firstParameter, to: value) { error in
            if (error != nil) {
                self.warnings("Unable to comply.", message: error!)
                textField.text = self.textbeforeediting
            }
        }
        
        updateTextFields()
    }
}
