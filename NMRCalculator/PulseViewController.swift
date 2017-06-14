//
//  ThirdViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/5/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class PulseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var PulseTableView: UITableView!
    
    var menuItems1: [String]?
    var menuItems2: [String]?
    var menuItems3: [String]?
    
    var itemValues1: [String]?
    var itemValues2: [String]?
    var itemValues3: [String]?
    
    var sections: [String]?
    var valueTextField1 = [UITextField]()
    var valueTextField2 = [UITextField]()
    var valueTextField3 = [UITextField]()
    
    var nmrCalc: NMRCalc?
    var activeField: UITextField?
    var textbeforeediting: String?
    
    var selectedItem: IndexPath?
    var indexForRelativePower: IndexPath?
    var fixedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        menuItems1 = [ "Pulse duration (μs)", "Flip angle (˚)", "RF Amplitude in Hz"]
        
        menuItems2 = [ "Pulse duration (μs)", "Flip angle (˚)", "RF Amplitude in Hz", "RF power relative to 1st (dB)"]
        
        menuItems3 = [ "Repetition Time (sec)", "Relaxation Time (sec)", "Ernst Angle (˚)" ]
        
        sections = ["1st Pulse", "2nd Pulse", "Ernst Angle"]
        
        indexForRelativePower = IndexPath(row: 3, section: 1)
        
        nmrCalc = NMRCalc()
        nmrCalc!.pulseNMR.append(NMRPulse(μs: 10.0, kHz: 25.0))
        nmrCalc!.pulseNMR.append(NMRPulse(μs: 10_000.0, kHz: 0.1))
        
        if nmrCalc!.calculate_dB() == false {
            warnings("Unable to comply.", message: "Cannot compare the powers.")
        }
        
        if nmrCalc!.set_ernstparameter("repetition", to: 1.0) == false {
            warnings("Unable to comply.", message: "Cannot initialize the repetition time.")
        }
        
        if nmrCalc!.set_ernstparameter("relaxation", to: 1.0) == false {
            warnings("Unable to comply.", message: "Cannot initialize the relaxation time.")
        }
        
        if nmrCalc!.evaluate_ernstparameter("angle") == false {
            warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
        }
        
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
        PulseTableView.contentInset = contentInsets
        PulseTableView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        PulseTableView.contentInset = contentInsets
        PulseTableView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: Update the textfields
    
    func update_textfields() {
        
        if let pulse = nmrCalc!.pulseNMR[0] {
            itemValues1 = [(pulse.duration)!.format(".5"),(pulse.flipangle)!.format(".4"), ((pulse.amplitude)!*1_000).format(".6") ]
            
            for k in 0..<valueTextField1.count {
                if let value = itemValues1?[k] {
                    valueTextField1[k].text = value
                }
                
/*                switch k {
                case 0:
                    if let tp = pulse.duration {
                        valueTextField1[k].text = tp.format(".5")
                    }
                case 1:
                    if let fa = pulse.flipangle {
                        valueTextField1[k].text = fa.format(".4")
                    }
                case 2:
                    if let amp = pulse.amplitude {
                        valueTextField1[k].text = (amp*1_000).format(".6")
                    }
                default:
                    break
                }*/
            }
            
        }
        
        if let pulse = nmrCalc!.pulseNMR[1] {
            itemValues2 = [(pulse.duration)!.format(".5"),(pulse.flipangle)!.format(".4"), ((pulse.amplitude)!*1_000).format(".6"), (nmrCalc!.relativepower)!.format(".5") ]
            
            for k in 0..<valueTextField2.count {
                switch k {
                case 0:
                    if let tp = pulse.duration {
                        valueTextField2[k].text = tp.format(".5")
                    }
                case 1:
                    if let fa = pulse.flipangle {
                        valueTextField2[k].text = fa.format(".4")
                    }
                case 2:
                    if let amp = pulse.amplitude {
                        valueTextField2[k].text = (amp*1_000).format(".6")
                    }
                case 3:
                    if let dB = nmrCalc!.relativepower {
                        valueTextField2[k].text = dB.format(".5")
                    }
                default:
                    break
                }
            }
        }
        
        if let calc = nmrCalc {
            itemValues3 = [(calc.repetitionTime)!.format(".3"),(calc.relaxationTime)!.format(".3"), ((calc.angleErnst)!*180.0/Double.pi).format(".4") ]
            
            for k in 0..<valueTextField3.count {
                switch k {
                case 0:
                    if let repetition = calc.repetitionTime {
                        valueTextField3[k].text = repetition.format(".3")
                    }
                case 1:
                    if let relaxation = calc.relaxationTime {
                        valueTextField3[k].text = relaxation.format(".3")
                    }
                case 2:
                    if let angle = calc.angleErnst {
                        valueTextField3[k].text = (angle * 180.0 / Double.pi).format(".4")
                    }
                default:
                    break
                }
            }
        }

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
        
        if let x = Double(textField.text!) {
            switch textField {
            case valueTextField1[0]: // Textfield for the duration of the 1st pulse
                
                guard nmrCalc!.set_pulseparameter("duration", of: 0, to_value: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    if nmrCalc!.evaluate_pulseparameter("amplitude", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    } else if nmrCalc!.evaluate_pulseparameter("flipangle", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems1![1] {
                    if nmrCalc!.evaluate_pulseparameter("amplitude", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                } else if fixedItem == menuItems1![2] {
                    if nmrCalc!.evaluate_pulseparameter("flipangle", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField1[1]: // Textfield for the flip angle of the 1st pulse
                
                guard nmrCalc!.set_pulseparameter("flipangle", of: 0, to_value: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluate_pulseparameter("amplitude", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                    break
                }
                
                if fixedItem == menuItems1![2] {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems1![0] {
                    if nmrCalc!.evaluate_pulseparameter("amplitude", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                }
                
            case valueTextField1[2]: // Textfield for the RF amplitude of the 1st pulse
                
                guard nmrCalc!.set_pulseparameter("amplitude", of: 0, to_value: x/1_000.0) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 0 else {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluate_pulseparameter("flipangle", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems1![1] {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems1![0] {
                    if nmrCalc!.evaluate_pulseparameter("flipangle", of: 0) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField2[0]: // Textfield for the duration of the second pulse
                
                guard nmrCalc!.set_pulseparameter("duration", of: 1, to_value: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    if nmrCalc!.evaluate_pulseparameter("amplitude", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    } else if nmrCalc!.evaluate_pulseparameter("flipangle", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems2![1] {
                    if nmrCalc!.evaluate_pulseparameter("amplitude", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                } else if fixedItem == menuItems2![2] {
                    if nmrCalc!.evaluate_pulseparameter("flipangle", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField2[1]: // Textfield for the flip angle of the second pulse
                
                guard nmrCalc!.set_pulseparameter("flipangle", of: 1, to_value: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
            
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluate_pulseparameter("amplitude", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                    break
                }
                
                if fixedItem == menuItems2![2] {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems2![0] {
                    if nmrCalc!.evaluate_pulseparameter("amplitude", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude.")
                    }
                }

            case valueTextField2[2]: // Textfield for the RF amplitude of the second pulse
                
                guard nmrCalc!.set_pulseparameter("amplitude", of: 1, to_value: x/1_000.0) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }

                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 1 else {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluate_pulseparameter("flipangle", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    break
                }
                
                if fixedItem == menuItems2![1] {
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                } else if fixedItem == menuItems2![0] {
                    if nmrCalc!.evaluate_pulseparameter("flipangle", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                }
                
            case valueTextField2[3]: // Textfield for the relative power
                // nmrCalc!.set_relativepower(x)
                nmrCalc!.relativepower = x
                
                if let amp0 =  nmrCalc!.pulseNMR[0]!.amplitude {
                    if nmrCalc!.set_pulseparameter("amplitude", of: 1, to_value: pow(10.0, 1.0 * x / 20.0) * amp0 ) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the amplitude of the second pulse.")
                    }
                    
                    if nmrCalc!.evaluate_pulseparameter("duration", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluate_pulseparameter("flipangle", of: 1) == false {
                        warnings("Unable to comply.", message: "Cannot calculate the flip angle.")
                    }
                    
                }
                
                if fixedItem != nil && selectedItem != nil {
                    PulseTableView.deselectRow(at: selectedItem!, animated: true)
                    if let cell = PulseTableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                        switch (selectedItem! as NSIndexPath).section {
                        case 0:
                            cell.itemLabel.text = menuItems1![(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = menuItems2![(selectedItem! as NSIndexPath).row]
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
                
                guard nmrCalc!.set_ernstparameter("repetition", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    if nmrCalc!.evaluate_ernstparameter("angle") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                    } else if nmrCalc!.evaluate_ernstparameter("relaxation") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxation time.")
                    }
                    break
                }
                
                if fixedItem == menuItems3![1] {
                    if nmrCalc!.evaluate_ernstparameter("angle") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                    }
                } else if fixedItem == menuItems3![2] {
                    if nmrCalc!.evaluate_ernstparameter("relaxation") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxtion time.")
                    }
                }

            case valueTextField3[1]:
                
                guard nmrCalc!.set_ernstparameter("relaxation", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    if nmrCalc!.evaluate_ernstparameter("angle") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                    } else if nmrCalc!.evaluate_ernstparameter("repetition") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the repetition time.")
                    }
                    break
                }
                
                if fixedItem == menuItems3![0] {
                    if nmrCalc!.evaluate_ernstparameter("angle") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the Ernst angle.")
                    }
                } else if fixedItem == menuItems3![2] {
                    if nmrCalc!.evaluate_ernstparameter("repetition") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the repetition time.")
                    }
                }
                
            case valueTextField3[2]:
                guard nmrCalc!.set_ernstparameter("angle", to: x * Double.pi / 180.0) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    break
                }
                
                guard let fixed = selectedItem, (fixed as NSIndexPath).section == 2 else {
                    if nmrCalc!.evaluate_ernstparameter("repetition") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the repetition time.")
                    } else if nmrCalc!.evaluate_ernstparameter("relaxation") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxation time.")
                    }
                    break
                }
                
                if fixedItem == menuItems3![0] {
                    if nmrCalc!.evaluate_ernstparameter("relaxation") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the relaxation time.")
                    }
                } else if fixedItem == menuItems3![1] {
                    if nmrCalc!.evaluate_ernstparameter("repetition") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the repetition time.")
                    }
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
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return menuItems1!.count
        case 1:
            return menuItems2!.count
        case 2:
            return menuItems3!.count
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
            labeltext = menuItems1![(indexPath as NSIndexPath).row]
            valuetext = itemValues1![(indexPath as NSIndexPath).row]
            valueTextField1.append(cell.itemValue)
        case 1:
            labeltext = menuItems2![(indexPath as NSIndexPath).row]
            valuetext = itemValues2![(indexPath as NSIndexPath).row]
            valueTextField2.append(cell.itemValue)
        case 2:
            labeltext = menuItems3![(indexPath as NSIndexPath).row]
            valuetext = itemValues3![(indexPath as NSIndexPath).row]
            valueTextField3.append(cell.itemValue)
        default:
            labeltext = nil
        }
        
        cell.itemLabel.text = labeltext
        cell.itemValue.text = valuetext
        
        return cell
    }
    
/*    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections![section]
    } */

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PulseTableViewHeader") as! PulseHeaderTableViewCell
        
        cell.pulseHeaderLabel.text = sections![section]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
/*    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PulseTableViewHeader") as! PulseHeaderTableViewCell
        
        cell.pulseHeaderLabel.text = sections![section]
        
        return cell
    } */
    
    // MARK: Warning messages
    
    func warnings(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath != indexForRelativePower {
            if selectedItem == nil {
                
                selectedItem = indexPath
                tableView.selectRow(at: selectedItem!, animated: true, scrollPosition: UITableViewScrollPosition.none)
                if let cell = tableView.cellForRow(at: selectedItem!) as? PulseTableViewCell {
                    fixedItem = cell.itemLabel.text
                    switch (selectedItem! as NSIndexPath).section {
                    case 0:
                        cell.itemLabel.text = "☒ " + menuItems1![(selectedItem! as NSIndexPath).row]
                    case 1:
                        cell.itemLabel.text = "☒ " + menuItems2![(selectedItem! as NSIndexPath).row]
                    case 2:
                        cell.itemLabel.text = "☒ " + menuItems3![(selectedItem! as NSIndexPath).row]
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
                            cell.itemLabel.text = menuItems1![(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = menuItems2![(selectedItem! as NSIndexPath).row]
                        case 2:
                            cell.itemLabel.text = menuItems3![(selectedItem! as NSIndexPath).row]
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
                            cell.itemLabel.text = menuItems1![(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = menuItems2![(selectedItem! as NSIndexPath).row]
                        case 2:
                            cell.itemLabel.text = menuItems3![(selectedItem! as NSIndexPath).row]
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
                            cell.itemLabel.text = "☒ " + menuItems1![(selectedItem! as NSIndexPath).row]
                        case 1:
                            cell.itemLabel.text = "☒ " + menuItems2![(selectedItem! as NSIndexPath).row]
                        case 2:
                            cell.itemLabel.text = "☒ " + menuItems3![(selectedItem! as NSIndexPath).row]
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
                    cell.itemLabel.text = menuItems1![(selectedItem! as NSIndexPath).row]
                case 1:
                    cell.itemLabel.text = menuItems2![(selectedItem! as NSIndexPath).row]
                case 2:
                    cell.itemLabel.text = menuItems3![(selectedItem! as NSIndexPath).row]
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
