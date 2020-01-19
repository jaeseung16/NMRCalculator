//
//  Fraction.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/15/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct Fraction {
    var positive: Bool
    var numerator: UInt
    var denominator: UInt
    
    func presentWithSlash() -> String {
        return (positive ? "" : "-") + "\(numerator)" + (denominator > 1 ? "/\(denominator)" : "")
    }
}
