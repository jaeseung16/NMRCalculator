//
//  Fraction.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/15/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct Fraction {
    static let slash = "/"
    
    var positive: Bool
    var numerator: UInt
    var denominator: UInt
    
    var inlineDescription: String {
        return (positive ? "" : "-") + "\(numerator)" + (denominator > 1 ? "/\(denominator)" : "")
    }
    
    static func isFraction(_ fraction: String) -> Bool {
        return fraction.contains(slash)
    }
    
    static func getNumeratorAndDenominator(_ fraction: String) -> (UInt, UInt) {
        var numerator: UInt
        var denominator: UInt = 1
        let invalidValue: UInt = UInt.max
        
        let fractionString = fraction
            .split(separator: Character(slash))
            .map {substring in String(substring)}
        
        if (fractionString.count == 2) {
            numerator = UInt(fractionString[0])!
            denominator = UInt(fractionString[1])!
        } else {
            numerator = invalidValue
        }
        
        return (numerator, denominator)
    }
}
