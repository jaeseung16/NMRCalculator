//
//  ErnstAngleCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

public class ErnstAngleCalculator: NMRCalcDelegate {
    
    private static let radianToDegree = 180.0 / Double.pi
    private static let degreeToRadian = Double.pi / 180.0
    
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        guard let request = request as? ErnstAngleRequest else {
            return .failure(.invalidInput)
        }
        
        switch (request.ernstAngleInDegree, request.repetitionTimeInSec, request.relaxationTimeInSec) {
        case (nil, let repetitionTimeInSec?, let relaxationTimeInSec?):
            return .success(ErnstAngleResponse(
                ernstAngleInDegree: acos( exp(-1.0 * repetitionTimeInSec / relaxationTimeInSec) ) * Self.radianToDegree,
                repetitionTimeInSec: repetitionTimeInSec,
                relaxationTimeInSec: relaxationTimeInSec
            ))
        case (let ernstAngleInDegree?, nil, let relaxationTimeInSec?):
            return .success(ErnstAngleResponse(
                ernstAngleInDegree: ernstAngleInDegree,
                repetitionTimeInSec: -1.0 * relaxationTimeInSec * log(cos(ernstAngleInDegree * Self.degreeToRadian)),
                relaxationTimeInSec: relaxationTimeInSec
            ))
        case (let ernstAngleInDegree?, let repetitionTimeInSec?, nil):
            return .success(ErnstAngleResponse(
                ernstAngleInDegree: ernstAngleInDegree,
                repetitionTimeInSec: repetitionTimeInSec,
                relaxationTimeInSec: -1.0 * repetitionTimeInSec / log(cos(ernstAngleInDegree * Self.degreeToRadian))
            ))
        default:
            return .failure(.invalidInput)
        }
    }

}
