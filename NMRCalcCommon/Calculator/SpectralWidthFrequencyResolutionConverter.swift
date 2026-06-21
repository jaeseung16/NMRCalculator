//
//  SpectralWidthFrequencyResolutionConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/11/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

class SpectralWidthFrequencyResolutionConverter {
    private static let logger = Logger()
    
    public var spectralWidth: Double // Hz
    public var numberOfPoints: Int
    public var frequencyResolution: Double // Hz
    
    public var spectralWidthInkHz: Double {
        return spectralWidth / 1000.0
    }
    
    private let delegate: NMRCalcDelegate
    private var error: NMRCalcError?
    
    public init(spectralWidth: Double, numberOfPoints: Int, frequencyResolution: Double) {
        self.spectralWidth = spectralWidth
        self.numberOfPoints = numberOfPoints
        self.frequencyResolution = frequencyResolution
        self.delegate = NMRCalcFactory.shared.create(.frequency)
    }
    
    public convenience init(spectralWidth: Double, frequencyResolution: Double) {
        self.init(spectralWidth: spectralWidth,
                  numberOfPoints: Int(spectralWidth / frequencyResolution),
                  frequencyResolution: frequencyResolution)
    }
    
    public convenience init(spectralWidth: Double, numberOfPoints: Int) {
        self.init(spectralWidth: spectralWidth,
                  numberOfPoints: numberOfPoints,
                  frequencyResolution: spectralWidth / Double(numberOfPoints))
    }
    
    public convenience init(frequencyResolution: Double, numberOfPoints: Int) {
        self.init(spectralWidth: Double(numberOfPoints) * frequencyResolution,
                  numberOfPoints: numberOfPoints,
                  frequencyResolution: frequencyResolution)
    }
    
    private func update(from response: FrequencyDomainResponse) {
        self.spectralWidth = response.spectralWidthInHz
        self.numberOfPoints = response.numberOfPoints
        self.frequencyResolution = response.frequencyResolutionInHz
    }
    
    private func process(_ request: NMRCalcRequest) {
        let result = delegate.process(request)
        switch result {
        case .success(let response):
            guard let response = response as? FrequencyDomainResponse else {
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

    public func set(spectralWidth: Double) -> Void {
        let request = FrequencyDomainRequest(spectralWidthInHz: spectralWidth, numberOfPoints: numberOfPoints)
        process(request)
    }
    
    public func set(spectralWidthInkHz: Double) -> Void {
        let request = FrequencyDomainRequest(spectralWidthInHz: spectralWidthInkHz * 1000.0, numberOfPoints: numberOfPoints)
        process(request)
    }
    
    public func set(frequencyResolution: Double) -> Void {
        let request = FrequencyDomainRequest(spectralWidthInHz: spectralWidth, frequencyResolutionInHz: frequencyResolution)
        process(request)
    }
    
    public func set(numberOfPoints: Int) -> Void {
        let request = FrequencyDomainRequest(spectralWidthInHz: spectralWidth, numberOfPoints: numberOfPoints)
        process(request)
    }
}
