//
//  SecondViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/8/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class SignalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        menuItems1 = [ "Number of data points", "Acquisition duration (sec)", "Dwell time (μs)"]
        
        menuItems2 = [ "Number of data points", "Spectral width (kHz)", "Frequency resolution (Hz)"]
        
        sections = ["Time domain", "Frequency domain"]
        
        nmrCalc = NMRCalc()
        
        if nmrCalc!.set_ACQparameter("size", to_value: 1000.0) == false {
            warnings("Unable to comply.", message: "The value is out of range.")
        }
        
        if nmrCalc!.set_ACQparameter("duration", to_value: 10.0) == false {
            
        }
        
        if nmrCalc!.evaluate_ACQparameter("dwell") == false {
            
        }
        
        if nmrCalc!.set_specparameter("size", to_value: 1000.0) == false {
            
        }
        
        if nmrCalc!.set_specparameter("width", to_value: 1.0) == false {
            
        }
        
        if nmrCalc!.evaluate_specparameter("resolution") == false {
            
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
        SignalTableView.contentInset = contentInsets
        SignalTableView.scrollIndicatorInsets = contentInsets
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        SignalTableView.contentInset = contentInsets
        SignalTableView.scrollIndicatorInsets = contentInsets
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: Update the textfields
    
    func update_textfields() {
        
        if let acq = nmrCalc!.acqNMR {
            itemValues1 = [ String(acq.size!), (acq.duration!/1_000.0).format(".3"), acq.dwell!.format(".3") ]
            
            for k in 0..<valueTextField1.count {
                switch k {
                case 0:
                    if let nofid = acq.size {
                        valueTextField1[k].text = "\(nofid)"
                    }
                case 1:
                    if let duration = acq.duration {
                        valueTextField1[k].text = (duration/1_000.0).format(".3")
                    }
                case 2:
                    if let dw = acq.dwell {
                        valueTextField1[k].text = dw.format(".3")
                    }
                default:
                    break
                }
            }
        }
        
        if let spec = nmrCalc!.specNMR {
            
            itemValues2 = [ String(spec.size!), (spec.width!).format(".3"), (spec.resolution!).format(".3") ]
        
            for k in 0..<valueTextField2.count {
                switch k {
                case 0:
                    if let nospec = spec.size {
                        valueTextField2[k].text = String(nospec)
                    }
                case 1:
                    if let specwidth = spec.width {
                        valueTextField2[k].text = specwidth.format(".3")
                    }
                case 2:
                    if let freqresol = spec.resolution {
                        valueTextField2[k].text = freqresol.format(".3")
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
            case valueTextField1[0]: // Textfield for the size of FID
                if nmrCalc!.set_ACQparameter("size", to_value: x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if nmrCalc!.set_ACQparameter("size", to_value: Double(textbeforeediting!)! ) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if let fixed = selectedItem {
                    if (fixed as NSIndexPath).section == 0 {
                        if fixedItem == menuItems1![1] {
                            if nmrCalc!.evaluate_ACQparameter("dwell") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the dwell time.")
                            }
                        } else if fixedItem == menuItems1![2] {
                            if nmrCalc!.evaluate_ACQparameter("duration") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the duration.")
                            }
                        }
                    } else {
                        if nmrCalc!.evaluate_ACQparameter("duration") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the duration.")
                        } else if nmrCalc!.evaluate_ACQparameter("dwell") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the dwell time.")
                        }
                    }
                } else {
                    if nmrCalc!.evaluate_ACQparameter("duration") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    } else if nmrCalc!.evaluate_ACQparameter("dwell") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the dwell time.")
                    }
                }
                
            case valueTextField1[1]: // Textfield for aquisition duration
                if nmrCalc!.set_ACQparameter("duration", to_value: x * 1_000.0) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if nmrCalc!.set_ACQparameter("duration", to_value: Double(textbeforeediting!)!) == false {
                        
                    }
                }
                
                if let fixed = selectedItem {
                    if (fixed as NSIndexPath).section == 0 {
                        if fixedItem == menuItems1![0] {
                            if nmrCalc!.evaluate_ACQparameter("dwell") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the dwell time.")
                            }
                        } else if fixedItem == menuItems1![2] {
                            if nmrCalc!.evaluate_ACQparameter("size") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                            }
                        }
                    } else {
                        if nmrCalc!.evaluate_ACQparameter("size") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                        } else if nmrCalc!.evaluate_ACQparameter("dwell") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the dwell time.")
                        }
                    }
                } else {
                    if nmrCalc!.evaluate_ACQparameter("size") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                    } else if nmrCalc!.evaluate_ACQparameter("dwell") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the dwell time.")
                    }
                }
                
            case valueTextField1[2]: // Textfield for dwell time
                if nmrCalc!.set_ACQparameter("dwell", to_value: x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if nmrCalc!.set_ACQparameter("dwell", to_value: Double(textbeforeediting!)!) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if let fixed = selectedItem {
                    if (fixed as NSIndexPath).section == 0 {
                        if fixedItem == menuItems1![0] {
                            if nmrCalc!.evaluate_ACQparameter("duration") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the duration.")
                            }
                        } else if fixedItem == menuItems1![1] {
                            if nmrCalc!.evaluate_ACQparameter("size") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                            }
                        }
                    } else {
                        if nmrCalc!.evaluate_ACQparameter("size") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                        } else if nmrCalc!.evaluate_ACQparameter("duration") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the duration.")
                        }
                    }
                } else {
                    if nmrCalc!.evaluate_ACQparameter("size") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                    } else if nmrCalc!.evaluate_ACQparameter("duration") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the duration.")
                    }
                }
                
            case valueTextField2[0]: // Textfield for the size of spectrum
                if nmrCalc!.set_specparameter("size", to_value: x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if nmrCalc!.set_specparameter("size", to_value: Double(textbeforeediting!)! ) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if let fixed = selectedItem {
                    if (fixed as NSIndexPath).section == 1 {
                        if fixedItem == menuItems2![1] {
                            if nmrCalc!.evaluate_specparameter("resolution") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the resolution.")
                            }
                        } else if fixedItem == menuItems2![2] {
                            if nmrCalc!.evaluate_specparameter("width") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the spectral width.")
                            }
                        }
                    } else {
                        if nmrCalc!.evaluate_specparameter("resolution") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the resolution.")
                        } else if nmrCalc!.evaluate_specparameter("width") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the spectral width.")
                        }
                    }
                } else {
                    if nmrCalc!.evaluate_specparameter("resolution") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the resolution.")
                    } else if nmrCalc!.evaluate_specparameter("width") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the spectral width.")
                    }
                }
                
            case valueTextField2[1]: // Textfield for spectral width
                if nmrCalc!.set_specparameter("width", to_value: x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if nmrCalc!.set_specparameter("width", to_value: Double(textbeforeediting!)! ) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if let fixed = selectedItem {
                    if (fixed as NSIndexPath).section == 1 {
                        if fixedItem == menuItems2![0] {
                            if nmrCalc!.evaluate_specparameter("resolution") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the resolution.")
                            }
                        } else if fixedItem == menuItems2![2] {
                            if nmrCalc!.evaluate_specparameter("size") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                            }
                        }
                    } else {
                        if nmrCalc!.evaluate_specparameter("resolution") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the resolution.")
                        } else if nmrCalc!.evaluate_specparameter("size") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                        }
                    }
                } else {
                    if nmrCalc!.evaluate_specparameter("resolution") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the resolution.")
                    } else if nmrCalc!.evaluate_specparameter("size") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                    }
                }
                
            case valueTextField2[2]: // Textfield for frequency resolution
                if nmrCalc!.set_specparameter("resolution", to_value: x) == false {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    if nmrCalc!.set_specparameter("resolution", to_value: Double(textbeforeediting!)!) == false {
                        warnings("Unable to comply.", message: "The value is out of range.")
                    }
                }
                
                if let fixed = selectedItem {
                    if (fixed as NSIndexPath).section == 1 {
                        if fixedItem == menuItems2![0] {
                            if nmrCalc!.evaluate_specparameter("width") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the spectral width.")
                            }
                        } else if fixedItem == menuItems2![1] {
                            if nmrCalc!.evaluate_specparameter("size") == false {
                                warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                            }
                        }
                    } else {
                        if nmrCalc!.evaluate_specparameter("width") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the spectral width.")
                        } else if nmrCalc!.evaluate_specparameter("size") == false {
                            warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                        }
                    }
                } else {
                    if nmrCalc!.evaluate_specparameter("width") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the spectral width.")
                    } else if nmrCalc!.evaluate_specparameter("size") == false {
                        warnings("Unable to comply.", message: "Cannot calculate the number of data points.")
                    }
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
    
    // MARK: Warning messages
    
    func warnings(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
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
    
    
/*    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections![section]
    } */
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignalTableViewHeader") as! SignalHeaderTableViewCell
        
        cell.signalHeaderLabel.text = sections![section]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedItem == nil {
            selectedItem = indexPath
            tableView.selectRow(at: selectedItem!, animated: true, scrollPosition: UITableViewScrollPosition.none)
            if let cell = tableView.cellForRow(at: selectedItem!) as? SignalTableViewCell {
                fixedItem = cell.itemLabel.text
                switch (selectedItem! as NSIndexPath).section {
                case 0:
                    cell.itemLabel.text = "☒ " + menuItems1![(selectedItem! as NSIndexPath).row]
                case 1:
                    cell.itemLabel.text = "☒ " + menuItems2![(selectedItem! as NSIndexPath).row]
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
                if let cell = tableView.cellForRow(at: selectedItem!) as? SignalTableViewCell {
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
                
            } else {
                
                tableView.deselectRow(at: selectedItem!, animated: true)
                if let cell = tableView.cellForRow(at: selectedItem!) as? SignalTableViewCell {
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
                
                selectedItem = indexPath
                tableView.selectRow(at: selectedItem!, animated: true, scrollPosition: UITableViewScrollPosition.none)
                if let cell = tableView.cellForRow(at: selectedItem!) as? SignalTableViewCell {
                    fixedItem = cell.itemLabel.text
                    switch (selectedItem! as NSIndexPath).section {
                    case 0:
                        cell.itemLabel.text = "☒ " + menuItems1![(selectedItem! as NSIndexPath).row]
                    case 1:
                        cell.itemLabel.text = "☒ " + menuItems2![(selectedItem! as NSIndexPath).row]
                    default:
                        break
                    }
                    cell.itemLabel.textColor = UIColor.gray
                    cell.itemValue.isEnabled = false
                    cell.itemValue.textColor = UIColor.gray
                }
                
            }
            
        }
        
    }
    
}

