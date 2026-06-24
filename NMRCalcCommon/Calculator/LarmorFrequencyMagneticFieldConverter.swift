//
//  FrequencyFieldConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/11/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

public class LarmorFrequencyMagneticFieldConverter {
    private static let logger = Logger()
    
    private static let γProton = NMRCalcConstants.gammaProton
    private static let γElectron = NMRCalcConstants.gammaElectron
    
    public let nucleus: NMRNucleus
    public var larmorFrequency: Double // Hz
    public var magneticField: Double // Tesla
    
    public var electronFrequency: Double
    public var protonFrequency: Double
    
    public var gyromagneticRatio: Double {
        return nucleus.γ
    }
    
    private let delegate: NMRCalcDelegate
    private var error: NMRCalcError?
    
    public init(nucleus: NMRNucleus,
                larmorFrequency: Double,
                magneticField: Double,
                protonFrequency: Double,
                electronFrequency: Double) {
        self.nucleus = nucleus
        self.larmorFrequency = larmorFrequency
        self.magneticField = magneticField
        self.protonFrequency = protonFrequency
        self.electronFrequency = electronFrequency
        self.delegate = NMRCalcFactory.shared.create(.larmor)
    }
    
    public convenience init(nucleus: NMRNucleus, magneticField: Double) {
        self.init(nucleus: nucleus,
                  larmorFrequency: nucleus.γ * magneticField,
                  magneticField: magneticField,
                  protonFrequency: Self.γProton * magneticField,
                  electronFrequency: Self.γElectron * magneticField)
    }
    
    public convenience init(nucleus: NMRNucleus, larmorFrequency: Double) {
        let magneticField = larmorFrequency / nucleus.γ
        self.init(nucleus: nucleus,
                  larmorFrequency: larmorFrequency,
                  magneticField: magneticField,
                  protonFrequency: Self.γProton * magneticField,
                  electronFrequency: Self.γElectron * magneticField)
    }
    
    private func update(from response: LarmorFrequencyResponse) {
        self.larmorFrequency = response.larmorFrequency
        self.magneticField = response.magneticField
        self.protonFrequency = response.protonFrequency
        self.electronFrequency = response.electronFrequency
    }
    
    private func process(_ request: NMRCalcRequest) {
        let result = delegate.process(request)
        switch result {
        case .success(let response):
            guard let response = response as? LarmorFrequencyResponse else {
                Self.logger.error("Invalid response type: \(type(of: response))")
                error = .invalidOutput
                break
            }
            update(from: response)
        case .failure(let error):
            Self.logger.error("Failed to process: \(String(describing: request))")
            self.error = error
        }
    }

    public func set(larmorFrequency: Double) -> Void {
        let request = LarmorFrequencyRequest(nucleus: nucleus, larmorFrequency: larmorFrequency)
        process(request)
    }
    
    public func set(electronFrequency: Double) -> Void {
        let request = LarmorFrequencyRequest(nucleus: nucleus, electronFrequency: electronFrequency)
        process(request)
    }
    
    public func set(protonFrequency: Double) -> Void {
        let request = LarmorFrequencyRequest(nucleus: nucleus, protonFrequency: protonFrequency)
        process(request)
    }
    
    public func set(magneticField: Double) -> Void {
        let request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: magneticField)
        process(request)
    }
    
}
