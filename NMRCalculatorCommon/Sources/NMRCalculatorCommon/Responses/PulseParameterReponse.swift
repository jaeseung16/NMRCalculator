//
//  PulseParameterReponse.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/20/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct PulseParameterResponse: NMRCalcResponse {
    public var calculationType = CalculatorType.pulse
    
    public let durationInMicrosecond: Double
    public let flipAngleInDegree: Double
    public let amplitudeInHz: Double
    
    public init(durationInMicrosecond: Double,
                flipAngleInDegree: Double,
                amplitudeInHz: Double) {
        self.durationInMicrosecond = durationInMicrosecond
        self.flipAngleInDegree = flipAngleInDegree
        self.amplitudeInHz = amplitudeInHz
    }
    
}
