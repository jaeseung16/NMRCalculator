//
//  SignalCalculator.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class PulseCalculator {
    static let shared = PulseCalculator()
    
    private let threeSixty = 360.0
    private let secToμs: Double = 1000000.0
    private var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    func updateAmplitude(flipAngle: Double, duration: Double) -> Double {
        return (flipAngle / threeSixty) / (duration * μsToSec)
    }
    
    func updateDuration(flipAngle: Double, amplitude: Double) -> Double {
        return (flipAngle / threeSixty) / amplitude * secToμs
    }
    
    func calculateDecibel(measured: Double, reference: Double) -> Double {
        return 20.0 * log10(abs(measured/reference))
    }
    
    func calculateRelativePower(amplitude1: Double, amplitude2: Double) -> Double {
        return 20.0 * log10(abs(amplitude2/amplitude1))
    }
    
    func calculateAmplitude(dB relativePower: Double, reference: Double) -> Double {
        return pow(10.0, 1.0 * relativePower / 20.0) * reference
    }
}
