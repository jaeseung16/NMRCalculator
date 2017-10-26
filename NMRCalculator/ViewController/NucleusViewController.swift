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
    @IBOutlet weak var NucleusTableView: UITableView!
    @IBOutlet weak var NucleusPicker: UIPickerView!
    @IBOutlet weak var nucleusName: UILabel!
    
    var nucleusTable: [String]?
    var nucleus: NMRNucleus?
    var proton: NMRNucleus?
    
    let numberofColumn = 1
    
    var menuItems: [String]?
    var itemValues: [String]?
    var valueTextField = [UITextField]()
    
    var nmrCalc: NMRCalc?
    var activeField: UITextField?
    var textbeforeediting: String?
    
    var sections: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.nucleusTable = readtable()
        
/*        let rotate = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        NucleusPicker.layer.anchorPoint = CGPointMake(0.75, 0.75)
        NucleusPicker.transform = rotate
        
        NucleusPicker.selectRow(0, inComponent: 0, animated: true)*/
        
        let tabbarviewcontroller = self.tabBarController  as! NMRCalcTabBarController
        nmrCalc = tabbarviewcontroller.nmrCalc
        
        proton = NMRNucleus(identifier: nucleusTable![0])
        nucleus = NMRNucleus(identifier: nucleusTable![0])
        
        nmrCalc!.nucleus = nucleus!
        
        guard nmrCalc!.setParameter("field", in: "resonance", to: 1.0) else {
            warnings("Unable to comply.", message: "The value is out of range.")
            return
        }
        
        let _ = nmrCalc!.evaluateParameter("larmor", in: "resonance")
        let _ = nmrCalc!.evaluateParameter("proton", in: "resonance")
        let _ = nmrCalc!.evaluateParameter("electron", in: "resonance")
        
        self.sections = [nmrCalc!.nucleus!.nameNucleus]
        
        self.menuItems = ["Larmor Frequency (MHz)", "External Magnetic Field (Tesla)", "Proton's Larmor Frequency (MHz)", "Electron's Larmor Frequency (GHz)"]
        
        update_textfields()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Initialize the nuclues table
    
    func readtable() -> [String]? {
        if let path = Bundle.main.path(forResource: "NMRFreqTable", ofType: "txt") {
            
            do {
                let table = try String(contentsOfFile: path, encoding: String.Encoding.utf8).components(separatedBy: "\n")
                
                return table
                
            } catch {
                print("Error: Cannot read the table.")
                return nil
            }
        }
        
        return nil
    }
    
    // MARK: Update the textfields
    
    func update_textfields() {
        if let larmor = nmrCalc?.larmorNMR {
            self.itemValues = [larmor.frequencyLarmor.format(".4"), larmor.fieldExternal.format(".4"), larmor.frequencyProton.format(".4"), larmor.frequencyElectron.format(".4")]
            
            for k in 0..<valueTextField.count {
                switch k {
                case 0:
                    valueTextField[k].text = larmor.frequencyLarmor.format(".4")
                    
                case 1:
                    valueTextField[k].text = larmor.fieldExternal.format(".4")
                    
                case 2:
                    valueTextField[k].text = larmor.frequencyProton.format(".4")
                    
                case 3:
                    valueTextField[k].text = larmor.frequencyElectron.format(".4")
                    
                default:
                    break
                }
            }
        }
        
        if let nucleus = nmrCalc?.nucleus {
            nucleusName.text = nucleus.nameNucleus
        }
    }
    
    // MARK: Methods for Keyboard
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let pickerSize = NucleusPicker.frame
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - pickerSize.height, 0.0)
        NucleusTableView.contentInset = contentInsets
        NucleusTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        NucleusTableView.contentInset = contentInsets
        NucleusTableView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func searchwebButtonDown(_ sender: UIButton) {
        var queryString = "https://www.google.com/search?q="
        queryString += nucleusName.text!
        queryString += "&oe=utf-8&ie=utf-8"
        
        let url : URL = URL(string: queryString)!
        
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
        return (nucleusTable?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 90.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 270.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let items = nucleusTable?[row] else {
            let label = UILabel()
            label.text = ""
            return label
        }
        
        if let label = view as! NucleusView! {
            return label
        } else {
            let label = NucleusView(frame: CGRect(x: 0, y: 0, width: 270.0, height: 90.0), nucleus: NMRNucleus(identifier: items))
            return label
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nucleus = NMRNucleus(identifier: nucleusTable![row])
        nmrCalc!.nucleus = nucleus!
        nmrCalc!.larmorNMR = NMRLarmor(nucleus: nucleus!)
        
        if nmrCalc!.setParameter("field", in: "resonance", to: Double(valueTextField[1].text!)!) == false {
            warnings("Unable to comply.", message: "The value is out of range.")
        }
        
        let _ = nmrCalc!.evaluateParameter("larmor", in: "resonance")
        let _ = nmrCalc!.evaluateParameter("proton", in: "resonance")
        let _ = nmrCalc!.evaluateParameter("electron", in: "resonance")
        
        update_textfields()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NucleusViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NucleusTableCell", for: indexPath) as! NucleusTableViewCell
        
        cell.itemLabel.text = menuItems![(indexPath as NSIndexPath).row]
        cell.itemValue.text = itemValues![(indexPath as NSIndexPath).row]
        valueTextField.append(cell.itemValue)
        
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension NucleusViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let selected = NucleusPicker.selectedRow(inComponent: 0)
        
        if selected == -1 {
            let alert = UIAlertController(title: "Unable to comply.", message: "Select a nucleus.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            
            return false
            
        } else {
            NucleusPicker.selectRow(selected, inComponent: 0, animated: true)
            nucleus = NMRNucleus(identifier: nucleusTable![selected])
            nmrCalc!.nucleus = nucleus
            nucleusName.text = nmrCalc!.nucleus!.nameNucleus
            
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        NucleusPicker.isUserInteractionEnabled = true
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NucleusPicker.isUserInteractionEnabled = false
        
        activeField = textField
        textbeforeediting = textField.text
        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let x = Double(textField.text!) {
            switch textField {
            case valueTextField[0]: // Textfield for larmor frequency
                guard nmrCalc!.setParameter("larmor", in: "resonance", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    return
                }
                
                let _ = nmrCalc!.evaluateParameter("proton", in: "resonance")
                let _ = nmrCalc!.evaluateParameter("electron", in: "resonance")
                
            case valueTextField[1]: // Textfield for external magnetic field
                guard nmrCalc!.setParameter("field", in: "resonance", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    return
                }
                
                let _ = nmrCalc!.evaluateParameter("larmor", in: "resonance")
                let _ = nmrCalc!.evaluateParameter("proton", in: "resonance")
                let _ = nmrCalc!.evaluateParameter("electron", in: "resonance")
                
            case valueTextField[2]: // Textfield for proton's larmor frequency
                guard nmrCalc!.setParameter("proton", in: "resonance", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    return
                }
                
                let _ = nmrCalc!.evaluateParameter("larmor", in: "resonance")
                let _ = nmrCalc!.evaluateParameter("electron", in: "resonance")
                
            case valueTextField[3]: // Textfield for electron's larmor frequency
                guard nmrCalc!.setParameter("electron", in: "resonance", to: x) else {
                    warnings("Unable to comply.", message: "The value is out of range.")
                    textField.text = textbeforeediting
                    return
                }
                
                let _ = nmrCalc!.evaluateParameter("larmor", in: "resonance")
                let _ = nmrCalc!.evaluateParameter("proton", in: "resonance")
                
            default:
                break
            }
            
        } else {
            textField.text = textbeforeediting
        }
        
        update_textfields()
        
        activeField = nil
    }
}

