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
    
    init(positive: Bool, numerator: UInt, denominator: UInt) {
        self.positive = positive
        self.numerator = numerator
        self.denominator = denominator
    }
    
    init(from input: String, isPositive: Bool) {
        self.positive = isPositive
        
        if (Fraction.isFraction(input)) {
            (self.numerator, self.denominator) = Fraction.getNumeratorAndDenominator(input)
        } else {
            self.numerator = UInt(input)!
            self.denominator = 1
        }
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
