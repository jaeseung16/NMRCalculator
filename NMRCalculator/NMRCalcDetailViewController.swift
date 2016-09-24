//
//  NMRCalcDetailViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/7/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class NMRCalcDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {


    @IBOutlet weak var NMRCalcScrollView: UIScrollView!
    
    @IBOutlet weak var NucleusPicker: UIPickerView!
    
    @IBOutlet weak var nucleusName: UILabel!
    
    @IBOutlet weak var resonancefrequency: UITextField!
    @IBOutlet weak var externalfieldT: UITextField!
    @IBOutlet weak var protonfrequency: UITextField!
    
    var nucleusTable: [String]?
    var nucleus: Nucleus?
    var proton: Nucleus?
    let numberofColumn = 1
    
    var nmrCalc: NMRCalc?
    
    var activeField: UITextField?
    var textbeforeediting: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nucleusTable = readtable()
        
        proton = Nucleus(identifier: nucleusTable![0])
        nucleus = Nucleus(identifier: nucleusTable![0])
        
        nmrCalc = NMRCalc(nucleus: nucleus!)
        nmrCalc!.set_resonance("field", to_value: 1.0)
        
        set_textfields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    // MARK: Initialize the nuclues table
    
    func readtable() -> [String]? {
        if let path = NSBundle.mainBundle().pathForResource("NMRFreqTable", ofType: "txt") {
            
            do {
                let table = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding).componentsSeparatedByString("\n")
                
                return table
                
            } catch {
                print("Error: Cannot read the table.")
                return nil
            }
        }
        
        return nil
    }
    
    // MARK: Update the textfields
    
    func set_textfields() {
        if let name = nmrCalc!.nucleus?.nameNucleus {
            nucleusName.text = name
        }
        
        if let B0 = nmrCalc!.fieldExternal {
            externalfieldT.text = B0.format(".3")
        }
        
        if let larmor = nmrCalc!.frequencyLarmor {
            resonancefrequency.text = larmor.format(".4")
        }
        
        if let protonfreq = nmrCalc!.frequencyProton {
            protonfrequency.text = protonfreq.format(".4")
        }
        
    }

    // MARK: UIPickerViewDelegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (nucleusTable?.count)!
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 135
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 375
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        /*        if let items = nucleusTable?[row].componentsSeparatedByString(" ") {
         if let label = view as! UILabel! {
         return label
         } else {
         let label = UILabel()
         label.text = items[1]
         return label
         }*/
        if let items = nucleusTable?[row] {
            if let label = view as! NucleusView! {
                return label
            } else {
                let label = NucleusView(frame: CGRect(x: 0, y: 0, width: 375, height: 135), nucleus: Nucleus(identifier: items))
                return label
            }
        } else {
            let label2 = UILabel()
            label2.text = ""
            return label2
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nucleus = Nucleus(identifier: nucleusTable![row])
        nmrCalc!.nucleus = nucleus!
        nmrCalc!.set_resonance("field", to_value: Double(externalfieldT.text!)!)
        
        set_textfields()
        
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        textbeforeediting = textField.text
        textField.text = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let x = Double(textField.text!) {
            switch textField {
            case resonancefrequency:
                nmrCalc!.set_resonance("larmor", to_value: x)
            case externalfieldT:
                nmrCalc!.set_resonance("field", to_value: x)
            case protonfrequency:
                nmrCalc!.set_resonance("proton", to_value: x)
            default:
                break
            }
            
            set_textfields()
            
        } else {
            textField.text = textbeforeediting
        }
        
        activeField = nil
    }
    
    // MARK: Keyboard
    
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        NMRCalcScrollView.contentInset = contentInsets
        NMRCalcScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        // print("\(kbSize.height) 2")
        if !CGRectContainsPoint(aRect, activeField!.frame.origin) {
            NMRCalcScrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        NMRCalcScrollView.contentInset = contentInsets
        NMRCalcScrollView.scrollIndicatorInsets = contentInsets
    }

}
