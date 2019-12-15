//
//  Nucleus.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/11/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRNucleus {
    // MARK: Properties
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
    
    // MARK: - Methods
    init() {
        identifier = "1H"
        nameNucleus = "Proton"
        atomicNumber = "1"
        atomicWeight = "1"
        symbolNucleus = "H"
        naturalAbundance = "99.9885"
        nuclearSpin = "1/2"
        gyromagneticRatio = String( 26.7522128 / 2.0 / Double.pi * 10.0 )
    }
    
    init(string: String) {
        let items = string.components(separatedBy: " ")
        
        identifier = items[0]
        nameNucleus = items[1]
        atomicNumber = items[2]
        atomicWeight = items[3]
        symbolNucleus = items[4]
        naturalAbundance = items[5]
        nuclearSpin = items[6]
        gyromagneticRatio = String( Double(items[7])! / 2.0 / Double.pi * 10.0 )
    }
    
    func describe() -> String {
        let string1 = "Nucleus: \(nameNucleus)"
        let string2 = "gyromagneticratio = \(γ) MHz/T"
        return string1 + "\n" + string2
    }
}
