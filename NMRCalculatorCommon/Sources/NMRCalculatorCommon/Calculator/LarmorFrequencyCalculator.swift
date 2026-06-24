//
//  LarmorFrequencyCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/17/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

import Logging

public class LarmorFrequencyCalculator: NMRCalcDelegate {
    private static let logger = Logger(label: "LarmorFrequencyCalculator")
    
    private static let γProton = NMRCalcConstants.gammaProton
    private static let γElectron = NMRCalcConstants.gammaElectron
    
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        Self.logger.info("Processing \(String(describing: request))")
        guard let request = request as? LarmorFrequencyRequest,
              let magneticField = magneticField(from: request) else {
            return .failure(.invalidInput)
        }

        let γNucleus = request.nucleus.γ
        let response = LarmorFrequencyResponse(
            nucleus: request.nucleus,
            magneticField: magneticField,
            larmorFrequency: γNucleus * magneticField,
            protonFrequency: Self.γProton * magneticField,
            electronFrequency: Self.γElectron * magneticField
        )

        return .success(response)
    }

    private func magneticField(from request: LarmorFrequencyRequest) -> Double? {
        switch (request.magneticField, request.larmorFrequency) {
        case (.some(let field), nil):
            return field
        case (nil, .some(let larmorFrequency)):
            return larmorFrequency / request.nucleus.γ
        case (nil, nil):
            if let protonFrequency = request.protonFrequency {
                return protonFrequency / Self.γProton
            } else if let electronFrequency = request.electronFrequency {
                return electronFrequency / Self.γElectron
            }
            return nil
        case (.some, .some):
            return nil
        }
    }
}
