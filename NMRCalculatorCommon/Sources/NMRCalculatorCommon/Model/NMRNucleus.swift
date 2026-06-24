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
    public let magneticMoment: String
    public let element: String
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
        magneticMoment = "2.792847351"
        element = "Hydrogen"
        gyromagneticRatio = String( 26.75221879 / 2.0 / Double.pi * 10.0 )
        
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
        magneticMoment = items[7]
        element = items[8]
        gyromagneticRatio = String( Double(items[9])! / 2.0 / Double.pi * 10.0 )
        
        id = identifier
    }
    
    public init(data: [String]) {
        identifier = data[0]
        nameNucleus = data[1]
        atomicNumber = data[2]
        atomicWeight = data[3]
        symbolNucleus = data[4]
        naturalAbundance = data[5]
        nuclearSpin = data[6]
        magneticMoment = data[7]
        element = data[8]
        gyromagneticRatio = String( Double(data[9])! / 2.0 / Double.pi * 10.0 )
        
        id = identifier
    }
    
    public var description: String {
        "\(nameNucleus): gyromagneticratio = \(γ) MHz/T"
    }
    
}
