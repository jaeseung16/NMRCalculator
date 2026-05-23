//
//  De.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/20/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct PulseParameterRequest: NMRCalcRequest {
    public var calculationType = CalculatorType.pulse
    
    public let durationInMicrosecond: Double?
    public let flipAngleInDegree: Double?
    public let amplitudeInHz: Double?
    
    public init(durationInMicrosecond: Double? = nil,
                flipAngleInDegree: Double? = nil,
                amplitudeInHz: Double? = nil) {
        self.durationInMicrosecond = durationInMicrosecond
        self.flipAngleInDegree = flipAngleInDegree
        self.amplitudeInHz = amplitudeInHz
    }
    
}
