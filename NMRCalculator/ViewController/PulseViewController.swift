//
//  ThirdViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/5/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class PulseViewController: UIViewController {
    // MARK: - Properties
    // Outlets
    @IBOutlet weak var pulseTableView: UITableView!
    
    // Constants
    let sections = ["1st Pulse", "2nd Pulse", "Ernst Angle"]
    
    let menuItems1 = [ "Pulse duration (μs)", "Flip angle (˚)", "RF Amplitude in Hz"]
    let menuItems2 = [ "Pulse duration (μs)", "Flip angle (˚)", "RF Amplitude in Hz", "RF power relative to 1st (dB)"]
    let menuItems3 = [ "Repetition Time (sec)", "Relaxation Time (sec)", "Ernst Angle (˚)" ]
    
    let indexForRelativePower = IndexPath(row: 3, section: 1)
    
    // Variables
    var itemValues1 = Array(repeating: String(), count: 3)
    var itemValues2 = Array(repeating: String(), count: 4)
    var itemValues3 = Array(repeating: String(), count: 3)
    
    var nmrCalc = NMRCalc.shared
    
    var selectedItem: IndexPath?
    var fixedItem: String?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Methods for Keyboard
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        pulseTableView.contentInset = contentInsets
        pulseTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        pulseTableView.contentInset = contentInsets
        pulseTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: Method to initialize the view
    func initializeView() {
        var pulse1 = NMRPulse()
        
        if let duration = UserDefaults.standard.object(forKey: "Duration1") as? Double {
            let _ = pulse1.set(parameter: "duration", to: duration)
        } else {
            let _ = pulse1.set(parameter: "duration", to: 10.0)
            UserDefaults.standard.set(10.0, forKey: "Duration1")
        }
        
        if let flipAngle = UserDefaults.standard.object(forKey: "FlipAngle1") as? Double {
            let _ = pulse1.set(parameter: "flipangle", to: flipAngle)
        } else {
            let _ = pulse1.set(parameter: "flipangle", to: 90.0)
            UserDefaults.standard.set(90.0, forKey: "FlipAngle1")
        }
   
        let _ = pulse1.update(parameter: "amplitude")
        
        var pulse2 = NMRPulse()
        
        if let amplitude = UserDefaults.standard.object(forKey: "Amplitude2") as? Double {
            let _ = pulse2.set(parameter: "amplitude", to: amplitude)
        } else {
            let _ = pulse2.set(parameter: "amplitude", to: 0.1)
            UserDefaults.standard.set(0.1, forKey: "Amplitude2")
        }
        
        if let flipAngle = UserDefaults.standard.object(forKey: "FlipAngle2") as? Double {
            let _ = pulse2.set(parameter: "flipangle", to: flipAngle)
        } else {
            let _ = pulse2.set(parameter: "flipangle", to: 360.0)
            UserDefaults.standard.set(360.0, forKey: "FlipAngle2")
        }
        
        let _ = pulse2.update(parameter: "duration")
        
        nmrCalc.pulseNMR.append(pulse1)
        nmrCalc.pulseNMR.append(pulse2)
        
        guard nmrCalc.calculate_dB() else {
            warnings("Unable to comply.", message: "Cannot compare the powers.")
            return
        }
        
        guard nmrCalc.set_ernstparameter("repetition", to: 1.0) else {
            warnings("Unable to comply.", message: "Cannot initialize the repetition time.")
            return
        }
        
        guard nmrCalc.set_ernstparameter("relaxation", to: 1.0) else {
            warnings("Unable to comply.", message: "Cannot initialize the relaxation time.")
            return
        }
        
        guard nmrCalc.evaluate_ernstparameter("angle") else {
            warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
            return
        }
        
        updateTextFields()
    }
    
    func updateTextFields() {
        updateItemValues()
        
        pulseTableView.reloadData()
    }
    
    func updateItemValues() {
        if let pulse = nmrCalc.pulseNMR[0] {
            itemValues1 = [(pulse.duration).format(".5"),(pulse.flipangle).format(".4"), ((pulse.amplitude)*1_000).format(".6") ]
            
            UserDefaults.standard.set(pulse.duration, forKey: "Duration1")
            UserDefaults.standard.set(pulse.flipangle, forKey: "FlipAngle1")
        }
        
        if let pulse = nmrCalc.pulseNMR[1] {
            itemValues2 = [(pulse.duration).format(".5"),(pulse.flipangle).format(".4"), ((pulse.amplitude)*1_000).format(".6"), ((nmrCalc.relativepower)?.format(".5"))! ]
            
            UserDefaults.standard.set(pulse.amplitude, forKey: "Amplitude2")
            UserDefaults.standard.set(pulse.flipangle, forKey: "FlipAngle2")
        }
        
        itemValues3 = [(nmrCalc.repetitionTime)!.format(".3"),(nmrCalc.relaxationTime)!.format(".3"), ((nmrCalc.angleErnst)!*180.0/Double.pi).format(".4") ]
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
extension PulseViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return menuItems1.count
        case 1:
            return menuItems2.count
        case 2:
            return menuItems3.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PulseTableCell", for: indexPath) as! PulseTableViewCell
        
        var labeltext: String?
        var valuetext: String?
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            labeltext = menuItems1[(indexPath as NSIndexPath).row]
            valuetext = itemValues1[(indexPath as NSIndexPath).row]
        case 1:
            labeltext = menuItems2[(indexPath as NSIndexPath).row]
            valuetext = itemValues2[(indexPath as NSIndexPath).row]
        case 2:
            labeltext = menuItems3[(indexPath as NSIndexPath).row]
            valuetext = itemValues3[(indexPath as NSIndexPath).row]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PulseTableViewHeader") as! PulseHeaderTableViewCell
        
        cell.pulseHeaderLabel.text = sections[section]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func toggleCellState(_ selectedItem: IndexPath, _ state: Bool) {
            guard let cell = tableView.cellForRow(at: selectedItem) as? PulseTableViewCell else {
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
            case 2:
                if state {
                    cell.itemLabel.text = menuItems3[(selectedItem as NSIndexPath).row]
                } else {
                    cell.itemLabel.text = "☒ " + menuItems3[(selectedItem as NSIndexPath).row]
                }
            default:
                break
            }
            cell.itemValue.isEnabled = state
            cell.itemValue.textColor = state ? .black : .gray
            cell.itemValue.text = cell.itemValue.text // Without this, textColor is not being updated.
            cell.itemLabel.textColor = state ? .black : .gray
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PulseTableViewCell else {
            return
        }
        
        guard cell.itemLabel.text != menuItems2[3] else {
            return
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

// MARK: - PulseTableViewCellDelegate
extension PulseViewController: PulseTableViewCellDelegate {
    func didEndEditing(_ cell: PulseTableViewCell, for cellLabel: UILabel, newValue: Double?, error: String?) {
        guard error == nil else {
            warnings("Unable to comply.", message: "The input was not a number.")
            return
        }
        
        guard let newValue = newValue else {
            return
        }
        
        var firstParameter = ""
        var secondParameter = ""
        var category = ""
        var value = newValue
        
        switch cell.sectionLabel! {
        case sections[0]:
            category = "pulse1"
            
            switch cellLabel.text! {
            case menuItems1[0]:
                firstParameter = "duration"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "amplitude"
                    break
                }
                
                if fixedItem == menuItems1[1] {
                    secondParameter = "amplitude"
                } else if fixedItem == menuItems1[2] {
                    secondParameter = "flipangle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems1[1]:
                firstParameter = "flipangle"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems1[2] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems1[0] {
                    secondParameter = "amplitude"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems1[2]:
                firstParameter = "amplitude"
                value = value / 1_000
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems1[1] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems1[0] {
                    secondParameter = "flipangle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            default:
                warnings("Unable to comply.", message: "The value is out of range.")
                return
            }
            
        case sections[1]:
            category = "pulse2"
            
            switch cellLabel.text! {
            case menuItems2[0]:
                firstParameter = "duration"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "amplitude"
                    break
                }
                
                if fixedItem == menuItems2[1] {
                    secondParameter = "amplitude"
                } else if fixedItem == menuItems2[2] {
                    secondParameter = "flipangle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[1]:
                firstParameter = "flipangle"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems2[2] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems2[0] {
                    secondParameter = "amplitude"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[2]:
                firstParameter = "amplitude"
                value = value / 1_000
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems2[1] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems2[0] {
                    secondParameter = "flipangle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[3]:
                nmrCalc.relativepower = value
                let amp0 = nmrCalc.pulseNMR[0]!.amplitude
                value = pow(10.0, 1.0 * value / 20.0) * amp0
                
                firstParameter = "amplitude"
                category = "pulse2"
                secondParameter = "duration"
                
            default:
                warnings("Unable to comply.", message: "The value is out of range.")
                return
            }
        case sections[2]:
            category = "ernstAngle"
            
            switch cellLabel.text! {
            case menuItems3[0]:
                firstParameter = "repetition"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    secondParameter = "angle"
                    break
                }
                
                if fixedItem == menuItems3[1] {
                    secondParameter = "angle"
                } else if fixedItem == menuItems3[2] {
                    secondParameter = "relaxation"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems3[1]:
                firstParameter = "relaxation"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    secondParameter = "angle"
                    break
                }
                
                if fixedItem == menuItems3[0] {
                    secondParameter = "angle"
                } else if fixedItem == menuItems3[2] {
                    secondParameter = "repetition"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems3[2]:
                firstParameter = "angle"
                value = value * Double.pi / 180.0
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    secondParameter = "repetition"
                    break
                }
                
                if fixedItem == menuItems3[0] {
                    secondParameter = "relaxation"
                } else if fixedItem == menuItems3[1] {
                    secondParameter = "repetition"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
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
        
        if nmrCalc.calculate_dB() == false {
            warnings("Unable to comply.", message: "Cannot compare the powers.")
        }
        
        updateTextFields()
    }
    
    
}
