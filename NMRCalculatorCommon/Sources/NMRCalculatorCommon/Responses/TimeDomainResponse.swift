//
//  TimeDomainResponse.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/18/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct TimeDomainResponse: NMRCalcResponse {
    public let calculationType = CalculatorType.time
    
    public let acqusitionTimeInSec: Double
    public let numberOfPoints: Int
    public let dwellInSec: Double
    
    public init(acqusitionTimeInSec: Double,
                numberOfPoints: Int,
                dwellInSec: Double) {
        self.acqusitionTimeInSec = acqusitionTimeInSec
        self.numberOfPoints = numberOfPoints
        self.dwellInSec = dwellInSec
    }
}
