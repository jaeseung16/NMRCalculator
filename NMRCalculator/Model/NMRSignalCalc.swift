//
//  NMRSignalCalc.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/27/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRSignalCalc {
    
    // MARK: Properties
    
    // var nucleus: NMRNucleus?
    // var larmorNMR: NMRLarmor?
    var fidNMR = NMRfid()
    var specNMR = NMRSpectrum()
    var fidCalc: NMRCalc2
    var specCalc: NMRCalc2
    
    // MARK: Methods
    
    init() {
        fidCalc = NMRCalc2(a: fidNMR.duration, b: Double(fidNMR.size), c: fidNMR.duration)
        specCalc = NMRCalc2(a: fidNMR.duration, b: Double(fidNMR.size), c: fidNMR.duration)
    }

}
