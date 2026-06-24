//
//  PulseParameterConveter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/27/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

public class PulseParameterConverter {
    private static let logger = Logger()
    
    public let pulse: Pulse
    public let nucleus: NMRNucleus
    
    private let delegate: NMRCalcDelegate
    private var error: NMRCalcError?
    
    public init(pulse: Pulse, nucleus: NMRNucleus) {
        self.pulse = pulse
        self.nucleus = nucleus
        self.delegate = NMRCalcFactory.shared.create(.pulse)
    }
    
    private func update(from response: PulseParameterResponse) {
        self.pulse.duration = response.durationInMicrosecond
        self.pulse.flipAngle = response.flipAngleInDegree
        self.pulse.amplitude = response.amplitudeInHz
    }
    
    private func process(_ request: NMRCalcRequest) {
        let result = delegate.process(request)
        switch result {
        case .success(let response):
            guard let response = response as? PulseParameterResponse else {
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
    
    public func set(duration: Double) {
        let request = PulseParameterRequest(durationInMicrosecond: duration, flipAngleInDegree: pulse.flipAngle)
        process(request)
    }
    
    public func set(flipAngle: Double) -> Void {
        let request = PulseParameterRequest(durationInMicrosecond: pulse.duration, flipAngleInDegree: flipAngle)
        process(request)
    }
    
    public func set(amplitude: Double) -> Void {
        let request = PulseParameterRequest(flipAngleInDegree: pulse.flipAngle, amplitudeInHz: amplitude)
        process(request)
    }
    
    public func set(amplitudeInT: Double) -> Void {
        let request = PulseParameterRequest(flipAngleInDegree: pulse.flipAngle, amplitudeInHz: amplitudeInT / nucleus.γ)
        process(request)
    }
}
