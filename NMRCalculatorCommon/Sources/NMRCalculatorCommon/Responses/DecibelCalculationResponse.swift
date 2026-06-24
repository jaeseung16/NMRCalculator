//
//  DecibelClaculationResponse.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/21/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct DecibelCalcualtionResponse: NMRCalcResponse {
    public let calculationType = CalculatorType.decibel
    
    public let dB: Double
    public let measured: Double
    public let reference: Double
    public let mode: DecibelMode
    
    public init(dB: Double,
                measured: Double,
                reference: Double,
                mode: DecibelMode = .power) {
        self.measured = measured
        self.reference = reference
        self.dB = dB
        self.mode = mode
    }
    
}
