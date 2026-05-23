//
//  FrequencyDomainCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/19/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public class FrequencyDomainCalculator: NMRCalcDelegate {
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        guard let request = request as? FrequencyDomainRequest else {
            return .failure(.invalidInput)
        }

        switch (request.spectralWidthInHz, request.numberOfPoints, request.frequencyResolutionInHz) {
        case (nil, let n?, let resolution?):
            return .success(TimeDomainResponse(
                acqusitionTimeInSec: Double(n) * resolution,
                numberOfPoints: n,
                dwellInSec: resolution
            ))
        case (let spectralWidth?, nil, let resolution?):
            return .success(TimeDomainResponse(
                acqusitionTimeInSec: spectralWidth,
                numberOfPoints: Int(spectralWidth / resolution),
                dwellInSec: resolution
            ))
        case (let spectralWidth?, let n?, nil):
            return .success(TimeDomainResponse(
                acqusitionTimeInSec: spectralWidth,
                numberOfPoints: n,
                dwellInSec: spectralWidth / Double(n)
            ))
        default:
            return .failure(.invalidInput)
        }
    }
}
