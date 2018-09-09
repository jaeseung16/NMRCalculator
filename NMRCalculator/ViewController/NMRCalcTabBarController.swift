//
//  NMRCalcTabBarController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/20/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class NMRCalcTabBarController: UITabBarController {
    // Properties
    var nmrCalc = NMRCalc()
    var periodicTable: NMRPeriodicTable!

    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
