//
//  ErnstAngleRequest.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/19/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct ErnstAngleRequest: NMRCalcRequest {
    public let calculationType = CalculatorType.ernst
    
    public let ernstAngleInDegree: Double?
    public let repetitionTimeInSec: Double?
    public let relaxationTimeInSec: Double?
    
    public init(ernstAngleInDegree: Double? = nil,
                repetitionTimeInSec: Double? = nil,
                relaxationTimeInSec: Double? = nil) {
        self.ernstAngleInDegree = ernstAngleInDegree
        self.repetitionTimeInSec = repetitionTimeInSec
        self.relaxationTimeInSec = relaxationTimeInSec
    }
    
}
