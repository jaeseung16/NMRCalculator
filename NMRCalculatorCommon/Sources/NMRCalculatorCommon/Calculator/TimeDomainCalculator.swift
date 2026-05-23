//
//  TimeDomainCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/18/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public class TimeDomainCalculator: NMRCalcDelegate {
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
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
            return .failure(.invalidInput)
        }
    }
}
