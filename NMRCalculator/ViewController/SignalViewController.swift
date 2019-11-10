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
    enum TimeMenu: Int {
        case size, duration, dwell
    }
    
    enum FrequencyMenu: Int {
        case size, width,resolution
    }

    let sections = ["Time domain", "Frequency domain"]
    let timeMenuItems: [TimeMenu: String] = [ .size: "Number of data points",
                                              .duration: "Acquisition duration (sec)",
                                              .dwell: "Dwell time (μs)"]
    let frequencyMenuItems: [FrequencyMenu: String] = [ .size: "Number of data points",
                                                        .width: "Spectral width (kHz)",
                                                        .resolution: "Frequency resolution (Hz)"]
    
    // Variables
    var nmrCalc = NMRCalc.shared
    
    var timeMenuItemValues: [TimeMenu: String] = [.size: "1000.0", .duration: "0.01", .dwell: "10.0"]
    var frequencyMenuItemValues: [FrequencyMenu: String] = [.size: "1000.0", .width: "1.0", .resolution: "1.0"]
    
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Methods for keyboard
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
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
            timeMenuItemValues[.size] = "\(acqDict[.size]!)"
            timeMenuItemValues[.duration] = (acqDict[.duration]! / 1_000.0).format(".3")
            timeMenuItemValues[.dwell] = acqDict[.dwell]!.format(".3")
            
            UserDefaults.standard.set(acqDict[.size], forKey: "SizeInAcquisition")
            UserDefaults.standard.set(acqDict[.duration], forKey: "DurationInAcquisition")
        }
        
        if let spec = nmrCalc.getSpec() {
            frequencyMenuItemValues[.size] = "\(spec[.size]!)"
            frequencyMenuItemValues[.width] = spec[.width]!.format(".3")
            frequencyMenuItemValues[.resolution] = spec[.resolution]!.format(".3")
            
            UserDefaults.standard.set(spec[.size], forKey: "SizeInSpectrum")
            UserDefaults.standard.set(spec[.width], forKey: "WidthInSpectrum")
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
            return timeMenuItems.count
        case 1:
            return frequencyMenuItems.count
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
            let menu = TimeMenu(rawValue: row)!
            labeltext = timeMenuItems[menu]
            valuetext = timeMenuItemValues[menu]
        case 1:
            let menu = FrequencyMenu(rawValue: row)!
            labeltext = frequencyMenuItems[menu]
            valuetext = frequencyMenuItemValues[menu]
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
            
            var labelText = (state ? "" : "☒ ")
            switch selectedItem.section {
            case 0:
                let menu = TimeMenu(rawValue: selectedItem.row)!
                labelText += timeMenuItems[menu]!
            case 1:
                let menu = FrequencyMenu(rawValue: selectedItem.row)!
                labelText += frequencyMenuItems[menu]!
            default:
                break
            }
            
            cell.update(state: state, labelText: labelText)
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
            case timeMenuItems[.size]: // Textfield for the size of FID
                firstParameter = "size"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == timeMenuItems[.duration] {
                    secondParameter = "dwell"
                } else if fixedItem == timeMenuItems[.dwell] {
                    secondParameter = "duration"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case timeMenuItems[.duration]: // Textfield for aquisition duration
                value = value * 1_000
                firstParameter = "duration"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "size"
                    break
                }
                
                if fixedItem == timeMenuItems[.size] {
                    secondParameter = "dwell"
                } else if fixedItem == timeMenuItems[.dwell] {
                    secondParameter = "size"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case timeMenuItems[.dwell]: // Textfield for dwell time
                firstParameter = "dwell"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "size"
                    break
                }
                
                if fixedItem == timeMenuItems[.size] {
                    secondParameter = "duration"
                } else if fixedItem == timeMenuItems[.duration] {
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
            case frequencyMenuItems[.size]: // Textfield for the size of spectrum
                firstParameter = "size"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "resolution"
                    break
                }
                
                if fixedItem == frequencyMenuItems[.width] {
                    secondParameter = "resolution"
                } else if fixedItem == frequencyMenuItems[.resolution] {
                    secondParameter = "width"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case frequencyMenuItems[.width]: // Textfield for spectral width
                firstParameter = "width"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "resolution"
                    break
                }
                
                if fixedItem == frequencyMenuItems[.size] {
                    secondParameter = "resolution"
                } else if fixedItem == frequencyMenuItems[.resolution] {
                    secondParameter = "size"
                } else {
                    warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case frequencyMenuItems[.resolution]: // Textfield for frequency resolution
                firstParameter = "resolution"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "width"
                    break
                }
                
                if fixedItem == frequencyMenuItems[.size] {
                    secondParameter = "width"
                } else if fixedItem == frequencyMenuItems[.width] {
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

