//
//  DecibelRequest.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/20/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct DecibelCalcualtionRequest: NMRCalcRequest {
    public var calculationType = CalculatorType.decibel
    
    public let dB: Double?
    public let measured: Double?
    public let reference: Double
    public let mode: DecibelMode
    
    public init(dB: Double? = nil,
                measured: Double? = nil,
                reference: Double,
                mode: DecibelMode = .power) {
        self.measured = measured
        self.reference = reference
        self.dB = dB
        self.mode = mode
    }
    
}
