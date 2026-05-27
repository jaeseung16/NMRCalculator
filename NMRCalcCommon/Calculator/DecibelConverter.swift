//
//  DecibelConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/27/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

class DecibelConverter {
    private static let logger = Logger()
    
    public var dB: Double
    public var measured: Double
    public var reference: Double
    public var mode: DecibelMode
    
    private let delegate: NMRCalcDelegate
    private var error: NMRCalcError?
    
    public init(dB: Double, measured: Double, reference: Double, mode: DecibelMode) {
        self.dB = dB
        self.measured = measured
        self.reference = reference
        self.mode = mode
        self.delegate = NMRCalcFactory.shared.create(.decibel)
    }
    
    public convenience init(measured: Double, reference: Double, mode: DecibelMode = .power) {
        self.init(dB: mode == .power ? 10.0 * log10(abs(measured/reference)) : 20.0 * log10(abs(measured/reference)),
                  measured: measured,
                  reference: reference,
                  mode: .amplitude)
    }
    
    private func update(from response: DecibelCalcualtionResponse) {
        self.dB = response.dB
        self.measured = response.measured
        self.reference = response.reference
        self.mode = response.mode
    }
    
    private func process(_ request: NMRCalcRequest) {
        let result = delegate.process(request)
        switch result {
        case .success(let response):
            guard let response = response as? DecibelCalcualtionResponse else {
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
    
    public func set(dB: Double, mode: DecibelMode) {
        let request = DecibelCalcualtionRequest(dB: dB, reference: reference, mode: mode)
        process(request)
    }
    
    public func update(measured: Double, reference: Double, mode: DecibelMode) {
        let request = DecibelCalcualtionRequest(measured: measured, reference: reference, mode: mode)
        process(request)
    }
    
}
