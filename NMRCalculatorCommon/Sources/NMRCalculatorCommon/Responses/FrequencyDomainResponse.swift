//
//  FrequencyDomainResponse.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/19/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct FrequencyDomainRespons: NMRCalcResponse {
    public var calculationType = CalculatorType.frequency
    
    public let spectralWidthInHz: Double
    public let numberOfPoints: Int
    public let frequencyResolutionInHz: Double
    
    public init(spectralWidthInHz: Double,
                numberOfPoints: Int,
                frequencyResolutionInHz: Double) {
        self.spectralWidthInHz = spectralWidthInHz
        self.numberOfPoints = numberOfPoints
        self.frequencyResolutionInHz = frequencyResolutionInHz
    }
}
