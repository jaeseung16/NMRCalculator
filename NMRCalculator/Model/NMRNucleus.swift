//
//  Nucleus.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/11/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRNucleus {
    // Properties
    var identifier: String
    var nameNucleus: String
    var atomicNumber: String
    var atomicWeight: String
    var symbolNucleus: String
    var naturalAbundance: String
    var nuclearSpin: String
    var gyromagneticRatio: String
    
    var γ: Double {
        get {
            return Double(gyromagneticRatio)!
        }
    }
    
    // MARK:- Methods
    init() {
        self.identifier = "1H"
        self.nameNucleus = "Proton"
        self.atomicNumber = "1"
        self.atomicWeight = "1"
        self.symbolNucleus = "H"
        self.naturalAbundance = "99.9885"
        self.nuclearSpin = "1/2"
        self.gyromagneticRatio = String( 26.7522128 / 2.0 / Double.pi * 10.0 )
    }
    
    init(identifier: String) {
        let items = identifier.components(separatedBy: " ")
        
        self.identifier = items[0]
        self.nameNucleus = items[1]
        self.atomicNumber = items[2]
        self.atomicWeight = items[3]
        self.symbolNucleus = items[4]
        self.naturalAbundance = items[5]
        self.nuclearSpin = items[6]
        self.gyromagneticRatio = String( Double(items[7])! / 2.0 / Double.pi * 10.0 )
    }
    
    func describe() -> String {
        let string1 = "Nucleus: \(nameNucleus)"
        let string2 = "gyromagneticratio = \(γ) MHz/T"
        
        return string1 + "\n" + string2
    }
}
