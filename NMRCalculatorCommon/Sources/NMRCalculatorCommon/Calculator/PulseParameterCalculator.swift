//
//  PulseParameterCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/20/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

public class PulseParameterCalculator: NMRCalcDelegate {
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        guard let request = request as? PulseParameterRequest else {
            return .failure(.invalidInput)
        }
        
        switch (request.durationInMicrosecond, request.flipAngleInDegree, request.amplitudeInHz) {
        case (nil, let flipAngleInDegree?, let amplitudeInHz?):
            return .success(PulseParameterResponse(
                durationInMicrosecond: (flipAngleInDegree/360.0) / amplitudeInHz * 1_000_000.0,
                flipAngleInDegree: flipAngleInDegree,
                amplitudeInHz: amplitudeInHz
            ))
        case (let durationInMicrosecond?, nil, let amplitudeInHz?):
            return .success(PulseParameterResponse(
                durationInMicrosecond: durationInMicrosecond,
                flipAngleInDegree: amplitudeInHz * (durationInMicrosecond / 1_000_000.0) * 360.0,
                amplitudeInHz: amplitudeInHz
            ))
        case (let durationInMicrosecond?, let flipAngleInDegree?, nil):
            return .success(PulseParameterResponse(
                durationInMicrosecond: durationInMicrosecond,
                flipAngleInDegree: flipAngleInDegree,
                amplitudeInHz: (flipAngleInDegree/360.0) / (durationInMicrosecond / 1_000_000.0)
            ))
        default:
            return .failure(.invalidInput)
        }
    }
}
