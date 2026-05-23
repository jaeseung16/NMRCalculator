//
//  DecibelCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

public class DecibelCalculator: NMRCalcDelegate {
    
    public func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError> {
        guard let request = request as? DecibelCalcualtionRequest else {
            return .failure(.invalidInput)
        }
        
        switch (request.dB, request.measured) {
        case (let dB?, nil):
            return .success(DecibelCalcualtionResponse(
                dB: dB,
                measured: request.mode == .power ? power(dB: dB, referencePower: request.reference): amplitude(dB: dB, referenceAmplitude: request.reference),
                reference: request.reference,
                mode: request.mode
            ))
        case (nil, let measured?):
            return .success(DecibelCalcualtionResponse(
                dB: request.mode == .power ? dB(measuredPower: measured, referencePower: request.reference): dB(measuredAmplitude: measured, referenceAmplitude: request.reference),
                measured: measured,
                reference: request.reference,
                mode: request.mode
            ))
        default:
            return .failure(.invalidInput)
        }
    }
    
    public func dB(measuredPower: Double, referencePower: Double) -> Double {
        return 10.0 * log10(abs(measuredPower/referencePower))
    }
    
    public func dB(measuredAmplitude: Double, referenceAmplitude: Double) -> Double {
        return 20.0 * log10(abs(measuredAmplitude/referenceAmplitude))
    }
    
    public func power(dB: Double, referencePower: Double) -> Double {
        return pow(10.0, dB / 10.0) * referencePower
    }
    
    public func amplitude(dB: Double, referenceAmplitude: Double) -> Double {
        return pow(10.0, dB / 20.0) * referenceAmplitude
    }
    
}
