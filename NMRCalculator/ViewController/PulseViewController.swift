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
    
    enum PulseMenu: Int {
        case duration, flipAngle, amplitude, dB
    }
    
    enum ErnstAngleMenu: Int {
        case repetition, relaxation, angleErnst
    }
    
    // Constants
    let sections = ["1st Pulse", "2nd Pulse", "Ernst Angle"]
    let indexForRelativePower = IndexPath(row: 3, section: 1)
    
    let menuItems1: [PulseMenu: String] = [.duration: "Pulse duration (μs)",
                                           .flipAngle: "Flip angle (˚)",
                                           .amplitude: "RF Amplitude in Hz"]
    let menuItems2: [PulseMenu: String] = [.duration: "Pulse duration (μs)",
                                           .flipAngle: "Flip angle (˚)",
                                           .amplitude: "RF Amplitude in Hz",
                                           .dB: "RF power relative to 1st (dB)"]
    let menuItems3: [ErnstAngleMenu: String] = [.repetition: "Repetition Time (sec)",
                                                .relaxation: "Relaxation Time (sec)",
                                                .angleErnst: "Ernst Angle (˚)"]
    
    // Variables
    var itemValues1: [PulseMenu: String] = [.duration: "10", .flipAngle: "90", .amplitude: "25000"]
    var itemValues2: [PulseMenu: String] = [.duration: "10000", .flipAngle: "360", .amplitude: "100", .dB: "-47.959"]
    var itemValues3: [ErnstAngleMenu: String] = [.repetition: "1", .relaxation: "1", .angleErnst: "68.42"]
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
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
            let _ = pulse1.set(parameter: NMRPulse.Parameter.duration, to: duration)
        } else {
            let _ = pulse1.set(parameter: NMRPulse.Parameter.duration, to: 10.0)
            UserDefaults.standard.set(10.0, forKey: "Duration1")
        }
        
        if let flipAngle = UserDefaults.standard.object(forKey: "FlipAngle1") as? Double {
            let _ = pulse1.set(parameter: NMRPulse.Parameter.flipAngle, to: flipAngle)
        } else {
            let _ = pulse1.set(parameter: NMRPulse.Parameter.flipAngle, to: 90.0)
            UserDefaults.standard.set(90.0, forKey: "FlipAngle1")
        }
   
        let _ = pulse1.update(parameter: NMRPulse.Parameter.amplitude)
        
        var pulse2 = NMRPulse()
        
        if let amplitude = UserDefaults.standard.object(forKey: "Amplitude2") as? Double {
            let _ = pulse2.set(parameter: NMRPulse.Parameter.amplitude, to: amplitude)
        } else {
            let _ = pulse2.set(parameter: NMRPulse.Parameter.amplitude, to: 0.1)
            UserDefaults.standard.set(0.1, forKey: "Amplitude2")
        }
        
        if let flipAngle = UserDefaults.standard.object(forKey: "FlipAngle2") as? Double {
            let _ = pulse2.set(parameter: NMRPulse.Parameter.flipAngle, to: flipAngle)
        } else {
            let _ = pulse2.set(parameter: NMRPulse.Parameter.flipAngle, to: 360.0)
            UserDefaults.standard.set(360.0, forKey: "FlipAngle2")
        }
        
        let _ = pulse2.update(parameter: NMRPulse.Parameter.duration)
        
        nmrCalc.pulseNMR.append(pulse1)
        nmrCalc.pulseNMR.append(pulse2)
        
        guard nmrCalc.calculate_dB() else {
            warnings("Unable to comply.", message: "Cannot compare the powers.")
            return
        }
        
        guard nmrCalc.setErnstParameter(.repetition, to: 1.0) else {
            warnings("Unable to comply.", message: "Cannot initialize the repetition time.")
            return
        }
        
        guard nmrCalc.setErnstParameter(.relaxation, to: 1.0) else {
            warnings("Unable to comply.", message: "Cannot initialize the relaxation time.")
            return
        }
        
        guard nmrCalc.evaluateErnstParameter(.angleErnst) else {
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
        if let pulse = nmrCalc.getPulse(index: 0) {
            itemValues1[.duration] = pulse[.duration]!.format(".5")
            itemValues1[.flipAngle] = pulse[.flipAngle]!.format(".4")
            itemValues1[.amplitude] = (pulse[.amplitude]! * 1_000).format(".6")
            
            UserDefaults.standard.set(pulse[.duration], forKey: "Duration1")
            UserDefaults.standard.set(pulse[.flipAngle], forKey: "FlipAngle1")
        }
        
        if let pulse = nmrCalc.getPulse(index: 1) {
            itemValues2[.duration] = pulse[.duration]!.format(".5")
            itemValues2[.flipAngle] = pulse[.flipAngle]!.format(".4")
            itemValues2[.amplitude] = (pulse[.amplitude]! * 1_000).format(".6")
            itemValues2[.dB] = ((nmrCalc.relativepower)?.format(".5"))!
            
            UserDefaults.standard.set(pulse[.amplitude], forKey: "Amplitude2")
            UserDefaults.standard.set(pulse[.flipAngle], forKey: "FlipAngle2")
        }
        
        if let ernstAngle = nmrCalc.getErnstAngle() {
            itemValues3[.repetition] = ernstAngle[.repetition]!.format(".3")
            itemValues3[.relaxation] = ernstAngle[.relaxation]!.format(".3")
            itemValues3[.angleErnst] = (ernstAngle[.angleErnst]! * 180.0 / Double.pi).format(".4")
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
        let row = indexPath.row
        
        var labeltext: String
        var valuetext: String?
        
        switch indexPath.section {
        case 0:
            let pulseMenu = PulseMenu(rawValue: row)!
            labeltext = menuItems1[pulseMenu]!
            valuetext = itemValues1[pulseMenu]
        case 1:
            let pulseMenu = PulseMenu(rawValue: row)!
            labeltext = menuItems2[pulseMenu]!
            valuetext = itemValues2[pulseMenu]
        case 2:
            let ernstAngleMenu = ErnstAngleMenu(rawValue: row)!
            labeltext = menuItems3[ernstAngleMenu]!
            valuetext = itemValues3[ernstAngleMenu]
        default:
            labeltext = ""
        }
        
        let fixed = labeltext == fixedItem
        
        if (fixed) {
            labeltext = "☒ " + labeltext
        }
        
        cell.itemValue.text = valuetext
        cell.sectionLabel = sections[indexPath.section]
        cell.delegate = self
        cell.update(state: !fixed, labelText: labeltext)
        
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
            
            let row = selectedItem.row;
            
            var labelText = (state ? "" : "☒ ")
            switch selectedItem.section {
            case 0:
                let pulseMenu = PulseMenu(rawValue: row)!
                labelText += menuItems1[pulseMenu]!
            case 1:
                let pulseMenu = PulseMenu(rawValue: row)!
                labelText += menuItems2[pulseMenu]!
            case 2:
                let ernstAngleMenu = ErnstAngleMenu(rawValue: row)!
                labelText += menuItems3[ernstAngleMenu]!
            default:
                break
            }
            
            cell.update(state: state, labelText: labelText)
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PulseTableViewCell else {
            return
        }
        
        guard cell.itemLabel.text != menuItems2[.dB] else {
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
        var category: NMRCalc.NMRCalcCategory
        var value = newValue
        
        switch cell.sectionLabel! {
        case sections[0]:
            category = .pulse1
            
            switch cellLabel.text! {
            case menuItems1[.duration]:
                firstParameter = "duration"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "amplitude"
                    break
                }
                
                if fixedItem == menuItems1[.flipAngle] {
                    secondParameter = "amplitude"
                } else if fixedItem == menuItems1[.amplitude] {
                    secondParameter = "flipAngle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems1[.flipAngle]:
                firstParameter = "flipAngle"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems1[.amplitude] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems1[.duration] {
                    secondParameter = "amplitude"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems1[.amplitude]:
                firstParameter = "amplitude"
                value = value / 1_000
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems1[.flipAngle] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems1[.duration] {
                    secondParameter = "flipAngle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            default:
                warnings("Unable to comply.", message: "The value is out of range.")
                return
            }
            
        case sections[1]:
            category = .pulse2
            
            switch cellLabel.text! {
            case menuItems2[.duration]:
                firstParameter = "duration"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "amplitude"
                    break
                }
                
                if fixedItem == menuItems2[.flipAngle] {
                    secondParameter = "amplitude"
                } else if fixedItem == menuItems2[.amplitude] {
                    secondParameter = "flipAngle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[.flipAngle]:
                firstParameter = "flipAngle"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems2[.amplitude] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems2[.duration] {
                    secondParameter = "amplitude"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[.amplitude]:
                firstParameter = "amplitude"
                value = value / 1_000
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    secondParameter = "duration"
                    break
                }
                
                if fixedItem == menuItems2[.flipAngle] {
                    secondParameter = "duration"
                } else if fixedItem == menuItems2[.duration] {
                    secondParameter = "flipAngle"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems2[.dB]:
                nmrCalc.relativepower = value
                let amp0 = nmrCalc.pulseNMR[0]!.amplitude
                value = pow(10.0, 1.0 * value / 20.0) * amp0
                
                firstParameter = "amplitude"
                category = .pulse2
                secondParameter = "duration"
                
            default:
                warnings("Unable to comply.", message: "The value is out of range.")
                return
            }
        case sections[2]:
            category = .ernstAngle
            
            switch cellLabel.text! {
            case menuItems3[.repetition]:
                firstParameter = "repetition"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    secondParameter = "angleErnst"
                    break
                }
                
                if fixedItem == menuItems3[.relaxation] {
                    secondParameter = "angleErnst"
                } else if fixedItem == menuItems3[.angleErnst] {
                    secondParameter = "relaxation"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems3[.relaxation]:
                firstParameter = "relaxation"
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    secondParameter = "angleErnst"
                    break
                }
                
                if fixedItem == menuItems3[.repetition] {
                    secondParameter = "angleErnst"
                } else if fixedItem == menuItems3[.angleErnst] {
                    secondParameter = "repetition"
                } else {
                    self.warnings("Unable to comply.", message: "Something is wrong.")
                    return
                }
                
            case menuItems3[.angleErnst]:
                firstParameter = "angleErnst"
                value = value * Double.pi / 180.0
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    secondParameter = "repetition"
                    break
                }
                
                if fixedItem == menuItems3[.repetition] {
                    secondParameter = "relaxation"
                } else if fixedItem == menuItems3[.relaxation] {
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
