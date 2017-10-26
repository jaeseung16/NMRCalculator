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

    // IBOutlets
    @IBOutlet weak var PulseTableView: UITableView!
    
    let menuItems1 = [ "Pulse duration (μs)", "Flip angle (˚)", "RF Amplitude in Hz"]
    let menuItems2 = [ "Pulse duration (μs)", "Flip angle (˚)", "RF Amplitude in Hz", "RF power relative to 1st (dB)"]
    let menuItems3 = [ "Repetition Time (sec)", "Relaxation Time (sec)", "Ernst Angle (˚)" ]
    
    var itemValues1: [String]?
    var itemValues2: [String]?
    var itemValues3: [String]?
    
    let sections = ["1st Pulse", "2nd Pulse", "Ernst Angle"]
    var valueTextField1 = Array(repeating: UITextField(), count: 3)
    var valueTextField2 = Array(repeating: UITextField(), count: 4)
    var valueTextField3 = Array(repeating: UITextField(), count: 3)
    
    var nmrCalc: NMRCalc?
    var activeField: UITextField?
    var textbeforeediting: String?
    
    var selectedItem: IndexPath?
    var fixedItem: String?
    let indexForRelativePower = IndexPath(row: 3, section: 1)
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if  UIDevice.current.userInterfaceIdiom == .phone {
            let tabbarviewcontroller = self.tabBarController as! NMRCalcTabBarController
            nmrCalc = tabbarviewcontroller.nmrCalc
        }
        
        var pulse1 = NMRPulse()
        let _ = pulse1.setParameter(parameter: "duration", to: 10.0)
        let _ = pulse1.setParameter(parameter: "flipangle", to: 90.0)
        let _ = pulse1.updateParameter(name: "amplitude")
        
        var pulse2 = NMRPulse()
        let _ = pulse2.setParameter(parameter: "amplitude", to: 0.1)
        let _ = pulse2.setParameter(parameter: "flipangle", to: 360.0)
        let _ = pulse2.updateParameter(name: "duration")
        
        nmrCalc!.pulseNMR.append(pulse1)
        nmrCalc!.pulseNMR.append(pulse2)
        
        guard nmrCalc!.calculate_dB() else {
            warnings("Unable to comply.", message: "Cannot compare the powers.")
            return
        }
        
        guard nmrCalc!.set_ernstparameter("repetition", to: 1.0) else {
            warnings("Unable to comply.", message: "Cannot initialize the repetition time.")
            return
        }
        
        guard nmrCalc!.set_ernstparameter("relaxation", to: 1.0) else {
            warnings("Unable to comply.", message: "Cannot initialize the relaxation time.")
            return
        }
        
        guard nmrCalc!.evaluate_ernstparameter("angle") else {
            warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
            return
        }
        
        update_textfields()
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
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        PulseTableView.contentInset = contentInsets
        PulseTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        PulseTableView.contentInset = contentInsets
        PulseTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: Method to update textfields
    func update_textfields() {
        if let pulse = nmrCalc!.pulseNMR[0] {
            itemValues1 = [(pulse.duration).format(".5"),(pulse.flipangle).format(".4"), ((pulse.amplitude)*1_000).format(".6") ]
            
            for k in 0..<valueTextField1.count {
                if let value = itemValues1?[k] {
                    valueTextField1[k].text = value
                }
            }
        }
        
        if let pulse = nmrCalc!.pulseNMR[1] {
            itemValues2 = [(pulse.duration).format(".5"),(pulse.flipangle).format(".4"), ((pulse.amplitude)*1_000).format(".6"), ((nmrCalc!.relativepower)?.format(".5"))! ]
            
            for k in 0..<valueTextField2.count {
                if let value = itemValues2?[k] {
                    valueTextField2[k].text = value
                }
            }
        }
        
        if let calc = nmrCalc {
            itemValues3 = [(calc.repetitionTime)!.format(".3"),(calc.relaxationTime)!.format(".3"), ((calc.angleErnst)!*180.0/Double.pi).format(".4") ]
            
            for k in 0..<valueTextField3.count {
                if let value = itemValues3?[k] {
                    valueTextField3[k].text = value
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
            valuetext = itemValues1![(indexPath as NSIndexPath).row]
            valueTextField1[(indexPath as NSIndexPath).row] = cell.itemValue
        case 1:
            labeltext = menuItems2[(indexPath as NSIndexPath).row]
            valuetext = itemValues2![(indexPath as NSIndexPath).row]
            valueTextField2[(indexPath as NSIndexPath).row] = cell.itemValue
        case 2:
            labeltext = menuItems3[(indexPath as NSIndexPath).row]
            valuetext = itemValues3![(indexPath as NSIndexPath).row]
            valueTextField3[(indexPath as NSIndexPath).row] = cell.itemValue
        default:
            labeltext = nil
        }
        
        cell.itemLabel.text = labeltext
        cell.itemValue.text = valuetext
        
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
        if indexPath != indexForRelativePower {
            if selectedItem == nil {
                
                selectedItem = indexPath
                tableView.selectRow(at: selectedItem!, animated: true, scrollPosition: UITableViewScrollPosition.none)
                if let cell = tableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                    fixedItem = cell.itemLabel.text
                    switch (selectedItem! as NSIndexPath).section {
                    case 0:
                        cell.itemLabel.text = "☒ " + menuItems1[(selectedItem! as NSIndexPath).row]
                    case 1:
                        cell.itemLabel.text = "☒ " + menuItems2[(selectedItem! as NSIndexPath).row]
                    case 2:
                        cell.itemLabel.text = "☒ " + menuItems3[(selectedItem! as NSIndexPath).row]
                    default:
                        break
                    }
                    cell.itemLabel.textColor = UIColor.gray
                    cell.itemValue.isEnabled = false
                    cell.itemValue.textColor = UIColor.gray
                }
            } else {
                if indexPath == selectedItem! {
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    if let cell = tableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                        switch (selectedItem! as NSIndexPath).section {
                        case 0:
                            cell.itemLabel.text = menuItems1[(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = menuItems2[(selectedItem! as NSIndexPath).row]
                        case 2:
                            cell.itemLabel.text = menuItems3[(selectedItem! as NSIndexPath).row]
                        default:
                            break
                        }
                        cell.itemLabel.textColor = UIColor.black
                        cell.itemValue.isEnabled = true
                        cell.itemValue.textColor = UIColor.black
                    }
                    
                    selectedItem = nil
                    fixedItem = nil
                } else {
                    tableView.deselectRow(at: selectedItem!, animated: true)
                    if let cell = tableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                        switch (selectedItem! as NSIndexPath).section {
                        case 0:
                            cell.itemLabel.text = menuItems1[(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = menuItems2[(selectedItem! as NSIndexPath).row]
                        case 2:
                            cell.itemLabel.text = menuItems3[(selectedItem! as NSIndexPath).row]
                        default:
                            break
                        }
                        cell.itemLabel.textColor = UIColor.black
                        cell.itemValue.isEnabled = true
                        cell.itemValue.textColor = UIColor.black
                    }
                    
                    selectedItem = indexPath
                    tableView.selectRow(at: selectedItem!, animated: true, scrollPosition: UITableViewScrollPosition.none)
                    if let cell = tableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                        fixedItem = cell.itemLabel.text
                        switch (selectedItem! as NSIndexPath).section {
                        case 0:
                            cell.itemLabel.text = "☒ " + menuItems1[(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = "☒ " + menuItems2[(selectedItem! as NSIndexPath).row]
                        case 2:
                            cell.itemLabel.text = "☒ " + menuItems3[(selectedItem! as NSIndexPath).row]
                        default:
                            break
                        }
                        cell.itemLabel.textColor = UIColor.gray
                        cell.itemValue.isEnabled = false
                        cell.itemValue.textColor = UIColor.gray
                    }
                }
            }
        } else if selectedItem != nil && fixedItem != nil {
            tableView.deselectRow(at: indexPath, animated: true)
            if let cell = tableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                switch (selectedItem! as NSIndexPath).section {
                case 0:
                    cell.itemLabel.text = menuItems1[(selectedItem! as NSIndexPath).row]
                case 1:
                    cell.itemLabel.text = menuItems2[(selectedItem! as NSIndexPath).row]
                case 2:
                    cell.itemLabel.text = menuItems3[(selectedItem! as NSIndexPath).row]
                default:
                    break
                }
                cell.itemLabel.textColor = UIColor.black
                cell.itemValue.isEnabled = true
                cell.itemValue.textColor = UIColor.black
            }
            
            selectedItem = nil
            fixedItem = nil
        }
    }
}

extension PulseViewController: UITextFieldDelegate {
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
        if let x = Double(textField.text!) {
            switch textField {
            case valueTextField1[0]: // Textfield for the duration of the 1st pulse
                guard nmrCalc!.setParameter("duration", in: "pulse1", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    if nmrCalc!.evaluateParameter("amplitude", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    } else if nmrCalc!.evaluateParameter("flipangle", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems1[1] {
                    if nmrCalc!.evaluateParameter("amplitude", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                } else if fixedItem == menuItems1[2] {
                    if nmrCalc!.evaluateParameter("flipangle", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField1[1]: // Textfield for the flip angle of the 1st pulse
                guard nmrCalc!.setParameter("flipangle", in: "pulse1", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluateParameter("amplitude", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                    break
                }
                
                if fixedItem == menuItems1[2] {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems1[0] {
                    if nmrCalc!.evaluateParameter("amplitude", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                }
                
            case valueTextField1[2]: // Textfield for the RF amplitude of the 1st pulse
                guard nmrCalc!.setParameter("amplitude", in: "pulse1", to: x/1_000.0) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluateParameter("flipangle", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems1[1] {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems1[0] {
                    if nmrCalc!.evaluateParameter("flipangle", in: "pulse1") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField2[0]: // Textfield for the duration of the second pulse
                guard nmrCalc!.setParameter("duration", in: "pulse2", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    if nmrCalc!.evaluateParameter("amplitude", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    } else if nmrCalc!.evaluateParameter("flipangle", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems2[1] {
                    if nmrCalc!.evaluateParameter("amplitude", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                } else if fixedItem == menuItems2[2] {
                    if nmrCalc!.evaluateParameter("flipangle", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField2[1]: // Textfield for the flip angle of the second pulse
                guard nmrCalc!.setParameter("flipangle", in: "pulse2", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluateParameter("amplitude", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                    break
                }
                
                if fixedItem == menuItems2[2] {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems2[0] {
                    if nmrCalc!.evaluateParameter("amplitude", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                }
                
            case valueTextField2[2]: // Textfield for the RF amplitude of the second pulse
                guard nmrCalc!.setParameter("amplitude", in: "pulse2", to: x/1_000.0) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluateParameter("flipangle", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems2[1] {
                    if nmrCalc!.evaluateParameter("duration", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems2[0] {
                    if nmrCalc!.evaluateParameter("flipangle", in: "pulse2") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField2[3]: // Textfield for the relative power
                // nmrCalc!.set_relativepower(x)
                nmrCalc!.relativepower = x
                
                let amp0 = nmrCalc!.pulseNMR[0]!.amplitude
                
                if nmrCalc!.setParameter("amplitude", in: "pulse2", to: pow(10.0, 1.0 * x / 20.0) * amp0 ) == false {
                    warnings("Unable to comply.", message: "Cannot calculate the amplitude of the second pulse.")
                }
                
                if nmrCalc!.evaluateParameter("duration", in: "pulse2") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the duration.")
                } else if nmrCalc!.evaluateParameter("flipangle", in: "pulse2") == false {
                    warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                }
                
                
                if fixedItem != nil && selectedItem != nil {
                    PulseTableView.deselectRow(at: selectedItem!, animated: true)
                    if let cell = PulseTableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                        switch (selectedItem! as NSIndexPath).section {
                        case 0:
                            cell.itemLabel.text = menuItems1[(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = menuItems2[(selectedItem! as NSIndexPath).row]
                        default:
                            break
                        }
                        cell.itemLabel.textColor = UIColor.black
                        cell.itemValue.isEnabled = true
                        cell.itemValue.textColor = UIColor.black
                    }
                    
                    selectedItem = nil
                    fixedItem = nil
                }
                
            case valueTextField3[0]:
                guard nmrCalc!.setParameter("repetition", in: "ernstAngle", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    guard nmrCalc!.evaluateParameter("angle", in: "ernstAngle") else {
                        guard nmrCalc!.evaluateParameter("relaxation", in: "ernstAngle")  else {
                            warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                            break
                        }
                        break
                    }
                    break
                }
                
                switch fixedItem! {
                case menuItems3[1]:
                    guard nmrCalc!.evaluateParameter("angle", in: "ernstAngle") else {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                        break
                    }
                case menuItems3[2]:
                    guard nmrCalc!.evaluateParameter("relaxation", in: "ernstAngle") else {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxtion time.")
                        break
                    }
                default:
                    break
                }
                
            case valueTextField3[1]:
                guard nmrCalc!.setParameter("relaxation", in: "ernstAngle", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    guard nmrCalc!.evaluateParameter("angle", in: "ernstAngle") else {
                        guard nmrCalc!.evaluateParameter("repetition", in: "ernstAngle")  else {
                            warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                            break
                        }
                        break
                    }
                    break
                }
                
                switch fixedItem! {
                case menuItems3[0]:
                    guard nmrCalc!.evaluateParameter("angle", in: "ernstAngle") else {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                        break
                    }
                case menuItems3[2]:
                    guard nmrCalc!.evaluateParameter("repetition", in: "ernstAngle") else {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxtion time.")
                        break
                    }
                default:
                    break
                }
                
            case valueTextField3[2]:
                guard nmrCalc!.setParameter("angle", in: "ernstAngle", to: x * Double.pi / 180.0) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    guard nmrCalc!.evaluateParameter("repetition", in: "ernstAngle") else {
                        guard nmrCalc!.evaluateParameter("relaxation", in: "ernstAngle")  else {
                            warnings("Unable to comply.", message: "Cannot calculate the relaxation time.")
                            break
                        }
                        break
                    }
                    break
                }
                
                switch fixedItem! {
                case menuItems3[0]:
                    guard nmrCalc!.evaluateParameter("relaxation", in: "ernstAngle") else {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                        break
                    }
                case menuItems3[1]:
                    guard nmrCalc!.evaluateParameter("repetition", in: "ernstAngle") else {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxtion time.")
                        break
                    }
                default:
                    break
                }
                
            default:
                break
            }
            
        } else {
            textField.text = textbeforeediting
        }
        
        if nmrCalc!.calculate_dB() == false {
            warnings("Unable to comply.", message: "Cannot compare the powers.")
        }
        
        update_textfields()
        activeField = nil
    }
    
}
