//
//  DecibelCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class DecibelCalculator {
    
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
