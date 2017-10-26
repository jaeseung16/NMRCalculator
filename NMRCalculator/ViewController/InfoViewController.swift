//
//  InfoViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var InfoTextView: UITextView!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        InfoTextView.isScrollEnabled = false;
        
        if let infotext = readInfo() {
            InfoTextView.attributedText = infotext
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        InfoTextView.isScrollEnabled = true;
    }

    // MARK: Method to read text for information
    func readInfo() -> NSAttributedString? {
        if let infourl = Bundle.main.url(forResource: "InfoText", withExtension: "rtf") {
            do {
                let infotext = try NSAttributedString(url: infourl, options:[NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.rtf] , documentAttributes: nil)
                
                return infotext
            } catch {
                print("Error: Cannot read the table.")
                return nil
            }
        }
        return nil
    }
}
