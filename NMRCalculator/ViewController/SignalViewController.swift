//
//  SecondViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/8/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SignalViewController: UIViewController {
    
    @IBOutlet weak var SignalTableView: UITableView!
    
    var menuItems1: [String]?
    var menuItems2: [String]?
    var itemValues1: [String]?
    var itemValues2: [String]?
    var sections: [String]?
    var valueTextField1 = [UITextField]()
    var valueTextField2 = [UITextField]()
    
    var nmrCalc: NMRCalc?
    var activeField: UITextField?
    var textbeforeediting: String?
    
    var selectedItem: IndexPath?
    var fixedItem: String?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuItems1 = [ "Number of data points", "Acquisition duration (sec)", "Dwell time (μs)"]
        menuItems2 = [ "Number of data points", "Spectral width (kHz)", "Frequency resolution (Hz)"]
        sections = ["Time domain", "Frequency domain"]
        
        if  UIDevice.current.userInterfaceIdiom == .phone {
            let tabbarviewcontroller = self.tabBarController as! NMRCalcTabBarController
            nmrCalc = tabbarviewcontroller.nmrCalc
        }
        
        guard nmrCalc!.setParameter("size", in: "acquisition", to: 1000.0),
            nmrCalc!.setParameter("duration", in: "acquisition", to: 10.0),
            nmrCalc!.evaluateParameter("dwell", in: "acquisition")
        else {
            warnings("Unable to comply.", message: "The value is out of range.")
            return
        }
        
        guard nmrCalc!.setParameter("size", in: "spectrum", to: 1000.0),
            nmrCalc!.setParameter("width", in: "spectrum", to: 1.0),
            nmrCalc!.evaluateParameter("resolution", in: "spectrum")
        else {
            warnings("Unable to comply.", message: "The value is out of range.")
            return
        }
        
        updateTextFields()
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
    
    // MARK: Methods for keyboard
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {

        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        SignalTableView.contentInset = contentInsets
        SignalTableView.scrollIndicatorInsets = contentInsets
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        SignalTableView.contentInset = contentInsets
        SignalTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: Methods to update textfields
    func updateTextFields() {
        if let acq = nmrCalc!.acqNMR {
            itemValues1 = [ String(acq.size), (acq.duration/1_000.0).format(".3"), acq.dwell.format(".3") ]
            
            for k in 0..<valueTextField1.count {
                switch k {
                case 0:
                    valueTextField1[k].text = "\(acq.size)"
                case 1:
                    valueTextField1[k].text = (acq.duration/1_000.0).format(".3")
                case 2:
                    valueTextField1[k].text = acq.dwell.format(".3")
                default:
                    break
                }
            }
        }
        
        if let spec = nmrCalc!.specNMR {
            itemValues2 = [ String(spec.size), (spec.width).format(".3"), (spec.resolution).format(".3") ]
        
            for k in 0..<valueTextField2.count {
                switch k {
                case 0:
                    valueTextField2[k].text = String(spec.size)
                case 1:
                    valueTextField2[k].text = spec.width.format(".3")
                case 2:
                    valueTextField2[k].text = spec.resolution.format(".3")
                default:
                    break
                }
            }
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SignalViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return menuItems1!.count
        case 1:
            return menuItems2!.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignalTableCell", for: indexPath) as! SignalTableViewCell
        
        var labeltext: String?
        var valuetext: String?
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            labeltext = menuItems1![(indexPath as NSIndexPath).row]
            valuetext = itemValues1![(indexPath as NSIndexPath).row]
            valueTextField1.append(cell.itemValue)
        case 1:
            labeltext = menuItems2![(indexPath as NSIndexPath).row]
            valuetext = itemValues2![(indexPath as NSIndexPath).row]
            valueTextField2.append(cell.itemValue)
        default:
            labeltext = nil
        }
        
        cell.itemLabel.text = labeltext
        cell.itemValue.text = valuetext
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignalTableViewHeader") as! SignalHeaderTableViewCell
        
        cell.signalHeaderLabel.text = sections![section]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func toggleCellState(_ selectedItem: IndexPath, _ state: Bool) {
            guard let cell = tableView.cellForRow(at: selectedItem) as? SignalTableViewCell else {
                return
            }
            
            fixedItem = state ? nil : cell.itemLabel.text
            
            switch (selectedItem as NSIndexPath).section {
            case 0:
                if state {
                    cell.itemLabel.text = menuItems1![(selectedItem as NSIndexPath).row]
                } else {
                    cell.itemLabel.text = "☒ " + menuItems1![(selectedItem as NSIndexPath).row]
                }
            case 1:
                if state {
                    cell.itemLabel.text = menuItems2![(selectedItem as NSIndexPath).row]
                } else {
                    cell.itemLabel.text = "☒ " + menuItems2![(selectedItem as NSIndexPath).row]
                }
            default:
                break
            }
            cell.itemValue.isEnabled = state
            cell.itemValue.textColor = state ? .black : .gray
            cell.itemValue.text = cell.itemValue.text // Without this, textColor is not being updated.
            cell.itemLabel.textColor = state ? .black : .gray
        }
        
        if let item = selectedItem {
            if indexPath == item {
                //tableView.deselectRow(at: indexPath, animated: true)
                toggleCellState(indexPath, true)
                selectedItem = nil
            } else {
                //tableView.deselectRow(at: item, animated: true)
                toggleCellState(item, true)
                toggleCellState(indexPath, false)
                selectedItem = indexPath
            }
        } else {
            //tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            toggleCellState(indexPath, false)
            selectedItem = indexPath
        }
    }
}

// MARK: - UITextFieldDelegate
extension SignalViewController: UITextFieldDelegate {
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
        activeField = nil
        
        guard let x = Double(textField.text!) else {
            warnings("Unable to comply.", message: "The input was not a number.")
            textField.text = textbeforeediting
            return
        }

        var firstParameter = ""
        var secondParameter = ""
        var category = ""
        var value = x
        
        switch textField {
        case valueTextField1[0]: // Textfield for the size of FID
            firstParameter = "size"
            category = "acquisition"
            
            guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                secondParameter = "duration"
                break
            }
            
            if fixedItem == menuItems1![1] {
                secondParameter = "dwell"
            } else if fixedItem == menuItems1![2] {
                secondParameter = "duration"
            } else {
                self.warnings("Unable to comply.", message: "Something is wrong.")
                textField.text = textbeforeediting
                return
            }
            
        case valueTextField1[1]: // Textfield for aquisition duration
            value = x * 1_000
            firstParameter = "duration"
            category = "acquisition"
            
            guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                secondParameter = "size"
                break
            }
            
            if fixedItem == menuItems1![0] {
                secondParameter = "dwell"
            } else if fixedItem == menuItems1![2] {
                secondParameter = "size"
            } else {
                self.warnings("Unable to comply.", message: "Something is wrong.")
                textField.text = textbeforeediting
                return
            }
            
        case valueTextField1[2]: // Textfield for dwell time
            value = x
            firstParameter = "dwell"
            category = "acquisition"
            
            guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                secondParameter = "size"
                break
            }
            
            if fixedItem == menuItems1![0] {
                secondParameter = "duration"
            } else if fixedItem == menuItems1![1] {
                secondParameter = "size"
            } else {
                self.warnings("Unable to comply.", message: "Something is wrong.")
                textField.text = textbeforeediting
                return
            }
            
        case valueTextField2[0]: // Textfield for the size of spectrum
            value = x
            firstParameter = "size"
            category = "spectrum"
            
            guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                secondParameter = "resolution"
                break
            }
            
            if fixedItem == menuItems2![1] {
                secondParameter = "resolution"
            } else if fixedItem == menuItems2![2] {
                secondParameter = "width"
            } else {
                self.warnings("Unable to comply.", message: "Something is wrong.")
                textField.text = textbeforeediting
                return
            }
            
        case valueTextField2[1]: // Textfield for spectral width
            value = x
            firstParameter = "width"
            category = "spectrum"
            
            guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                secondParameter = "resolution"
                break
            }
            
            if fixedItem == menuItems2![0] {
                secondParameter = "resolution"
            } else if fixedItem == menuItems2![2] {
                secondParameter = "size"
            } else {
                self.warnings("Unable to comply.", message: "Something is wrong.")
                textField.text = textbeforeediting
                return
            }
            
        case valueTextField2[2]: // Textfield for frequency resolution
            value = x
            firstParameter = "resolution"
            category = "spectrum"
            
            guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                secondParameter = "width"
                break
            }
            
            if fixedItem == menuItems2![0] {
                secondParameter = "width"
            } else if fixedItem == menuItems2![1] {
                secondParameter = "size"
            } else {
                self.warnings("Unable to comply.", message: "Something is wrong.")
                textField.text = textbeforeediting
                return
            }
            
        default:
            warnings("Unable to comply.", message: "The value is out of range.")
            textField.text = textbeforeediting
            return
        }

        nmrCalc!.updateParameter(firstParameter, in: category, to: value, and: secondParameter) { error in
            if (error != nil) {
                self.warnings("Unable to comply.", message: error!)
                textField.text = self.textbeforeediting
            }
        }
        
        updateTextFields()
    }
}

