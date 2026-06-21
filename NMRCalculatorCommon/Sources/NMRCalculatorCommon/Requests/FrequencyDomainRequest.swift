//
//  FrequencyDomainRequest.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/19/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct FrequencyDomainRequest: NMRCalcRequest {
    public let calculationType = CalculatorType.frequency
    
    public let spectralWidthInHz: Double?
    public let numberOfPoints: Int?
    public let frequencyResolutionInHz: Double?
    
    public init(spectralWidthInHz: Double? = nil,
                numberOfPoints: Int? = nil,
                frequencyResolutionInHz: Double? = nil) {
        self.spectralWidthInHz = spectralWidthInHz
        self.numberOfPoints = numberOfPoints
        self.frequencyResolutionInHz = frequencyResolutionInHz
    }
}
