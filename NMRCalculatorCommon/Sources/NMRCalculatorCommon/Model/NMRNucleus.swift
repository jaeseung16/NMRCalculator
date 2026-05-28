//
//  Nucleus.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/11/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

public struct NMRNucleus: Hashable, CustomStringConvertible, Identifiable, Sendable {
    public let id: String
    
    public let identifier: String
    public let nameNucleus: String
    public let atomicNumber: String
    public let atomicWeight: String
    public let symbolNucleus: String
    public let naturalAbundance: String
    public let nuclearSpin: String
    public let gyromagneticRatio: String
    
    public var γ: Double {
        get {
            return Double(gyromagneticRatio)!
        }
    }
    
    public init() {
        identifier = "1H"
        nameNucleus = "Proton"
        atomicNumber = "1"
        atomicWeight = "1"
        symbolNucleus = "H"
        naturalAbundance = "99.9885"
        nuclearSpin = "1/2"
        gyromagneticRatio = String( 26.7522128 / 2.0 / Double.pi * 10.0 )
        
        id = identifier
    }
    
    public init(string: String) {
        let items = string.components(separatedBy: " ")
        
        identifier = items[0]
        nameNucleus = items[1]
        atomicNumber = items[2]
        atomicWeight = items[3]
        symbolNucleus = items[4]
        naturalAbundance = items[5]
        nuclearSpin = items[6]
        gyromagneticRatio = String( Double(items[7])! / 2.0 / Double.pi * 10.0 )
        
        id = identifier
    }
    
    public var description: String {
        "\(nameNucleus): gyromagneticratio = \(γ) MHz/T"
    }
    
}
