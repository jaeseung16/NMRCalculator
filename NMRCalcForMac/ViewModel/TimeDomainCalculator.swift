//
//  FrequencyTimeCalculator.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class TimeDomainCalculator {
    static let shared = TimeDomainCalculator()
    
    private let secToμs: Double = 1000000.0
    private var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    func calculateDwellTime(totalDuration: Double, numberOfDataPoints: Double) -> Double {
        return totalDuration * secToμs / numberOfDataPoints
    }
    
    func calculateTotalDuration(dwellTime: Double, numberOfDataPoints: Double) -> Double {
        return numberOfDataPoints * (dwellTime * μsToSec)
    }
    
}
