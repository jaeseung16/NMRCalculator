//
//  TimeDomainRequest.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/18/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct TimeDomainRequest: NMRCalcRequest {
    public let calculationType = CalculatorType.time
    
    public let acqusitionTimeInSec: Double?
    public let numberOfPoints: Int?
    public let dwellInSec: Double?
    
    public init(acqusitionTimeInSec: Double? = nil,
                numberOfPoints: Int? = nil,
                dwellInSec: Double? = nil) {
        self.acqusitionTimeInSec = acqusitionTimeInSec
        self.numberOfPoints = numberOfPoints
        self.dwellInSec = dwellInSec
    }
}
