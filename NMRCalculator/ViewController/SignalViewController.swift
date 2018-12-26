//
//  SecondViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/8/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SignalViewController: UIViewController {
    // MARK: - Properties
    // Outlets
    @IBOutlet weak var signalTableView: UITableView!
    
    // Constants
    let sections = ["Time domain", "Frequency domain"]
    let menuItems1 = [ "Number of data points", "Acquisition duration (sec)", "Dwell time (μs)"]
    let menuItems2 = [ "Number of data points", "Spectral width (kHz)", "Frequency resolution (Hz)"]
    
    enum Menu1: Int {
        case size, duration, dwell
    }
    
    // Variables
    var nmrCalc = NMRCalc.shared
    
    var itemValues1: [Menu1: String] = [.size: "1000.0", .duration: "0.01", .dwell: "10.0"]
    var itemValues2 = Array(repeating: String(), count: 3)
    
    var selectedItem: IndexPath?
    var fixedItem: String?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        super.viewWillDisappear(animated)
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
        signalTableView.contentInset = contentInsets
        signalTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        signalTableView.contentInset = contentInsets
        signalTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: Methods to initialize the view
    func initializeView() {
        if let size = UserDefaults.standard.object(forKey: "SizeInAcquisition") as? Double {
            let _ = nmrCalc.setParameter("size", in: .acquisition, to: size)
        } else {
            let _ = nmrCalc.setParameter("size", in: .acquisition, to: 1000.0)
            UserDefaults.standard.set(1000.0, forKey: "SizeInAcquisition")
        }
        
        if let duration = UserDefaults.standard.object(forKey: "DurationInAcquisition") as? Double {
            let _ = nmrCalc.setParameter("duration", in: .acquisition, to: duration)
        } else {
            let _ = nmrCalc.setParameter("duration", in: .acquisition, to: 10.0)
            UserDefaults.standard.set(10.0, forKey: "DurationInAcquisition")
        }
        
        guard nmrCalc.evaluate(parameter: "dwell", in: .acquisition) else {
                warnings("Unable to comply.", message: "The value is out of range.")
                return
        }
        
        if let size = UserDefaults.standard.object(forKey: "SizeInSpectrum") as? Double {
            let _ = nmrCalc.setParameter("size", in: .spectrum, to: size)
        } else {
            let _ = nmrCalc.setParameter("size", in: .spectrum, to: 1000.0)
            UserDefaults.standard.set(1000.0, forKey: "SizeInSpectrum")
        }
        
        if let width = UserDefaults.standard.object(forKey: "WidthInSpectrum") as? Double {
            let _ = nmrCalc.setParameter("width", in: .spectrum, to: width)
        } else {
            let _ = nmrCalc.setParameter("width", in: .spectrum, to: 1.0)
            UserDefaults.standard.set(1.0, forKey: "WidthInSpectrum")
        }
        
        guard nmrCalc.evaluate(parameter: "resolution", in: .spectrum) else {
                warnings("Unable to comply.", message: "The value is out of range.")
                return
        }
        
        updateTextFields()
    }
    
    func updateTextFields() {
        if let acqDict = nmrCalc.getAcq() {
            itemValues1[.size] = "\(acqDict[.size]!)"
            itemValues1[.duration] = (acqDict[.duration]! / 1_000.0).format(".3")
            itemValues1[.dwell] = acqDict[.dwell]!.format(".3")
            
            UserDefaults.standard.set(acqDict[.size], forKey: "SizeInAcquisition")
            UserDefaults.standard.set(acqDict[.duration], forKey: "DurationInAcquisition")
        }
        
        if let spec = nmrCalc.specNMR {
            itemValues2 = [ "\(spec.size)", (spec.width).format(".3"), (spec.resolution).format(".3") ]
            
            UserDefaults.standard.set(spec.size, forKey: "SizeInSpectrum")
            UserDefaults.standard.set(spec.width, forKey: "WidthInSpectrum")
        }
        
        signalTableView.reloadData()
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return menuItems1.count
        case 1:
            return menuItems2.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignalTableCell", for: indexPath) as! SignalTableViewCell
        
        var labeltext: String?
        var valuetext: String?
        
        let row = (indexPath as NSIndexPath).row
        switch (indexPath as NSIndexPath).section {
        case 0:
            labeltext = menuItems1[row]
            valuetext = itemValues1[Menu1(rawValue: row)!]
        case 1:
            labeltext = menuItems2[(indexPath as NSIndexPath).row]
            valuetext = itemValues2[(indexPath as NSIndexPath).row]
        default:
            labeltext = nil
        }
        
        cell.itemLabel.text = labeltext
        cell.itemValue.text = valuetext
        cell.sectionLabel = sections[indexPath.section]
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignalTableViewHeader") as! SignalHeaderTableViewCell
        
        cell.signalHeaderLabel.text = sections[section]
        
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
                    cell.itemLabel.text = menuItems1[(selectedItem as NSIndexPath).row]
                } else {
                    cell.itemLabel.text = "☒ " + menuItems1[(selectedItem as NSIndexPath).row]
                }
            case 1:
                if state {
                    cell.itemLabel.text = menuItems2[(selectedItem as NSIndexPath).row]
                } else {
                    cell.itemLabel.text = "☒ " + menuItems2[(selectedItem as NSIndexPath).row]
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
                toggleCellState(indexPath, true)
                selectedItem = nil
            } else {
                toggleCellState(item, true)
                toggleCellState(indexPath, false)
                selectedItem = indexPath
            }
        } else {
            toggleCellState(indexPath, false)
            selectedItem = indexPath
        }
    }
}

// MARK: - SignalTableViewCellDelegate
extension SignalViewController: SignalTableViewCellDelegate {
    func didEndEditing(_ cell: SignalTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?) {
        guard error == nil else {
            warnings("Unable to comply.", message: "The input was not a number.")
            return
        }
        
        guard let newValue = newValue else {
            return
        }
        
        var firstParameter = ""
        var secondParameter = ""
        var category: NMRCalc.NMRCalcCategory
        var value = newValue
        
        switch cell.sectionLabel! {
        case sections[0]:
            category = .acquisition
            
            switch cellLabel.text! {
            case menuItems1[0]: // Textfield for the size of FID
                firstParameter = "size"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems1[1] {
                    secondParameter = "dwell"
                } else if fixedItem == menuItems1[2] {
                    secondParameter = "duration"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems1[1]: // Textfield for aquisition duration
                value = value * 1_000
                firstParameter = "duration"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "size"
                    break
                }
                
                if fixedItem == menuItems1[0] {
                    secondParameter = "dwell"
                } else if fixedItem == menuItems1[2] {
                    secondParameter = "size"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems1[2]: // Textfield for dwell time
                firstParameter = "dwell"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "size"
                    break
                }
                
                if fixedItem == menuItems1[0] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems1[1] {
                    secondParameter = "size"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            default:
                warnings("Unable to comply.", message: "The value is out of range.")
                return
            }
        case sections[1]:
            category = .spectrum
            
            switch cellLabel.text! {
            case menuItems2[0]: // Textfield for the size of spectrum
                firstParameter = "size"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "resolution"
                    break
                }
                
                if fixedItem == menuItems2[1] {
                    secondParameter = "resolution"
                } else if fixedItem == menuItems2[2] {
                    secondParameter = "width"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[1]: // Textfield for spectral width
                firstParameter = "width"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "resolution"
                    break
                }
                
                if fixedItem == menuItems2[0] {
                    secondParameter = "resolution"
                } else if fixedItem == menuItems2[2] {
                    secondParameter = "size"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[2]: // Textfield for frequency resolution
                firstParameter = "resolution"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "width"
                    break
                }
                
                if fixedItem == menuItems2[0] {
                    secondParameter = "width"
                } else if fixedItem == menuItems2[1] {
                    secondParameter = "size"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            default:
                warnings("Unable to comply.", message: "The value is out of range.")
                return
            }
        
        default:
            warnings("Unable to comply.", message: "The value is out of range.")
            return
        }
        
        nmrCalc.updateParameter(firstParameter, in: category, to: value, and: secondParameter) { error in
            if (error != nil) {
                self.warnings("Unable to comply.", message: error!)
            }
        }
        
        updateTextFields()
    }
}

