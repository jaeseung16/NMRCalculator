//
//  Nucleus.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/11/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation


class Nucleus {
    var identifier: String?
    var nameNucleus: String?
    var atomicNumber: String?
    var atomicWeight: String?
    var symbolNucleus: String?
    var naturalabundance: String?
    var nuclearspin: String?
    var gyromagneticratio: String?
    
    init(identifier: String) {
        let items = identifier.components(separatedBy: " ")

        self.identifier = items[0]
        self.nameNucleus = items[1]
        self.atomicNumber = items[2]
        self.atomicWeight = items[3]
        self.symbolNucleus = items[4]
        self.naturalabundance = items[5]
        self.nuclearspin = items[6]
        self.gyromagneticratio = String( Double(items[7])! / 2.0 / Double.pi * 10.0 )
    }

}
