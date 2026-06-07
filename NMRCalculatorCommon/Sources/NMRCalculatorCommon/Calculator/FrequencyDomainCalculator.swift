//
//  FrequencyDomainCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/19/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

import Logging

public class FrequencyDomainCalculator: NMRCalcDelegate {
    private static let logger = Logger(label: "FrequencyDomainCalculator")
    
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        Self.logger.info("Processing \(String(describing: request))")
        guard let request = request as? FrequencyDomainRequest else {
            return .failure(.invalidInput)
        }

        switch (request.spectralWidthInHz, request.numberOfPoints, request.frequencyResolutionInHz) {
        case (nil, let n?, let resolution?):
            return .success(FrequencyDomainResponse(
                spectralWidthInHz: Double(n) * resolution,
                numberOfPoints: n,
                frequencyResolutionInHz: resolution
            ))
        case (let spectralWidth?, nil, let resolution?):
            return .success(FrequencyDomainResponse(
                spectralWidthInHz: spectralWidth,
                numberOfPoints: Int(spectralWidth / resolution),
                frequencyResolutionInHz: resolution
            ))
        case (let spectralWidth?, let n?, nil):
            return .success(FrequencyDomainResponse(
                spectralWidthInHz: spectralWidth,
                numberOfPoints: n,
                frequencyResolutionInHz: spectralWidth / Double(n)
            ))
        default:
            Self.logger.info("\(String(describing: request.spectralWidthInHz)), \(String(describing: request.numberOfPoints)), \(String(describing: request.frequencyResolutionInHz))")
            return .failure(.invalidInput)
        }
    }
}
