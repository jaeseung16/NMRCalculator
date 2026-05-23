//
//  ErnstAngleResponse.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/19/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct ErnstAngleResponse: NMRCalcResponse {
    public var calculationType = CalculatorType.ernst
    
    public var ernstAngleInDegree: Double
    public var repetitionTimeInSec: Double
    public var relaxationTimeInSec: Double
    
    public init(ernstAngleInDegree: Double,
                repetitionTimeInSec: Double,
                relaxationTimeInSec: Double) {
        self.ernstAngleInDegree = ernstAngleInDegree
        self.repetitionTimeInSec = repetitionTimeInSec
        self.relaxationTimeInSec = relaxationTimeInSec
    }
    
}
