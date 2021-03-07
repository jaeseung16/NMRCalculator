//
//  MacNMRPulseCalculator.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Foundation

class PulseCalculatorViewModel: ObservableObject {
    @Published var duration1: Double?
    @Published var flipAngle1: Double?
    @Published var amplitude1: Double?
    @Published var duration2: Double?
    @Published var flipAngle2: Double?
    @Published var amplitude2: Double?
    @Published var relativePower: Double?
    
    private let secToμs: Double = 1000000.0
    private var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    private func updateAmplitude(flipAngle: Double, duration: Double) -> Double {
        return (flipAngle / 360.0) / (duration * μsToSec)
    }
    
    private func updateDuration(flipAngle: Double, amplitude: Double) -> Double {
        return (flipAngle / 360.0) / amplitude * secToμs
    }
    
    private func calculateRelativePower() -> Void {
         if let amp1 = amplitude1 {
             if let amp2 = amplitude2 {
                 relativePower = 20.0 * log10(abs(amp2/amp1))
             }
         }
     }
    
    func duration1Updated() -> Void {
        if flipAngle1 == nil {
            flipAngle1 = 90.0
        }
        
        if duration1 == nil {
            duration1 = 10
        }
        
        amplitude1 = updateAmplitude(flipAngle: flipAngle1!, duration: duration1!)
        calculateRelativePower()
    }
    
    func duration2Updated() -> Void {
        if flipAngle2 == nil {
            flipAngle2 = 90.0
        }
        
        if duration2 == nil {
            duration2 = 10
        }
        
        amplitude2 = updateAmplitude(flipAngle: flipAngle2!, duration: duration2!)
        calculateRelativePower()
    }
    
    func flipAngle1Updated() -> Void {
        if flipAngle1 == nil {
            flipAngle1 = 90.0
        }
        
        if duration1 == nil {
            duration1 = 10.0
        }
        
        amplitude1 = updateAmplitude(flipAngle: flipAngle1!, duration: duration1!)
        calculateRelativePower()
    }
    
    func flipAngle2Updated() -> Void {
        if flipAngle2 == nil {
            flipAngle2 = 90.0
        }
        
        if duration2 == nil {
            duration2 = 10.0
        }
        
        amplitude2 = updateAmplitude(flipAngle: flipAngle2!, duration: duration2!)
        calculateRelativePower()
    }
    
    func amplitude1Updated() -> Void {
        if flipAngle1 == nil {
            flipAngle1 = 90.0
        }
        
        if amplitude1 == nil {
            amplitude1 = 25000
        }
        
        duration1 = updateDuration(flipAngle: flipAngle1!, amplitude: amplitude1!)
        calculateRelativePower()
    }
    
    func amplitude2Updated() -> Void {
        if flipAngle2 == nil {
            flipAngle2 = 90.0
        }
        
        if amplitude2 == nil {
            amplitude2 = 25000
        }
        
        duration2 = updateDuration(flipAngle: flipAngle2!, amplitude: amplitude2!)
        calculateRelativePower()
    }

    func relativePowerUpdated() -> Void {
        guard let amp1 = amplitude1 else {
            return
        }
        
        amplitude2 = pow(10.0, 1.0 * relativePower! / 20.0) * amp1
    }
}
