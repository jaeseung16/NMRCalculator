//
//  TimeDomainCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/18/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

import Logging

public class TimeDomainCalculator: NMRCalcDelegate {
    private static let logger = Logger(label: "TimeDomainCalculator")
    
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        Self.logger.info("Processing \(String(describing: request))")
        guard let request = request as? TimeDomainRequest else {
            return .failure(.invalidInput)
        }

        switch (request.acqusitionTimeInSec, request.numberOfPoints, request.dwellInSec) {
        case (nil, let n?, let dwell?):
            return .success(TimeDomainResponse(
                acqusitionTimeInSec: Double(n) * dwell,
                numberOfPoints: n,
                dwellInSec: dwell
            ))
        case (let acq?, nil, let dwell?):
            return .success(TimeDomainResponse(
                acqusitionTimeInSec: acq,
                numberOfPoints: Int(acq / dwell),
                dwellInSec: dwell
            ))
        case (let acq?, let n?, nil):
            return .success(TimeDomainResponse(
                acqusitionTimeInSec: acq,
                numberOfPoints: n,
                dwellInSec: acq / Double(n)
            ))
        default:
            Self.logger.info("\(String(describing: request.acqusitionTimeInSec)), \(String(describing: request.numberOfPoints)), \(String(describing: request.dwellInSec))")
            return .failure(.invalidInput)
        }
    }
}
