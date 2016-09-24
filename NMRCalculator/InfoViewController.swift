//
//  InfoViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var InfoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        InfoTextView.isScrollEnabled = false;
        
        if let infotext = readinfo() {
            InfoTextView.attributedText = infotext
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        InfoTextView.isScrollEnabled = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Initialize the Info text
    
    func readinfo() -> NSAttributedString? {
        if let infourl = Bundle.main.url(forResource: "InfoText", withExtension: "rtf") {
            
            do {
                let infotext = try NSAttributedString(url: infourl, options:[NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType] , documentAttributes: nil)
                
                return infotext
                
            } catch {
                print("Error: Cannot read the table.")
                return nil
            }
        }
        
        return nil
    }
    

}
