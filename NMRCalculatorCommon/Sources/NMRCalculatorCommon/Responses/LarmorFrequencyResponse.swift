//
//  LarmorFrequencyResponse.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/16/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public struct LarmorFrequencyResponse: NMRCalcResponse {
    public let calculationType = CalculatorType.larmor
    
    public let nucleus: NMRNucleus
    public let magneticField: Double
    public let larmorFrequency: Double
    public let protonFrequency: Double
    public let electronFrequency: Double
    
    public init(nucleus: NMRNucleus,
                magneticField: Double,
                larmorFrequency: Double,
                protonFrequency: Double,
                electronFrequency: Double) {
        self.nucleus = nucleus
        self.magneticField = magneticField
        self.larmorFrequency = larmorFrequency
        self.protonFrequency = protonFrequency
        self.electronFrequency = electronFrequency
    }
    
}
