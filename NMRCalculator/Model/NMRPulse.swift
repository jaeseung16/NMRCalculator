//
//  NMRPulse.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRPulse {
    var duration: Double = 10.0 // pulse duration in μs
    var flipAngle: Double = 90.0 // flip angle in degree
    var amplitude: Double // RF amplitude in kHz
    
    enum Parameter: String {
        case duration
        case flipAngle
        case amplitude
    }
    
    // MARK:- Methods
    init() {
        amplitude = ( flipAngle / duration ) * ( 1000.0 / 360.0 )
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .amplitude:
            amplitude = value
            
        case .duration:
            guard value >= 0 else { return false }
            duration = value
            
        case .flipAngle:
            flipAngle = value
        }
        
        return true
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .duration:
            guard (amplitude != 0) else { return false }
            duration = pulseDuration(with: flipAngle / 360.0, at: amplitude / 1000.0)
            
        case .amplitude:
            guard (duration != 0) else { return false }
            amplitude = pulseAmplitude(with: flipAngle / 360.0, for: duration) * 1000.0
            
        case .flipAngle:
            flipAngle = rotationAngle(at: amplitude / 1000.0, for: duration) * 360.0
        }
        
        return true
    }
    
    mutating func rotationAngle(at amplitude: Double, for duration: Double) -> Double {
        return amplitude * duration
    }
    
    mutating func pulseAmplitude(with rotationAngle: Double, for duration: Double) -> Double {
        return rotationAngle / duration
    }
    
    mutating func pulseDuration(with rotationAngle: Double, at amplitude: Double) -> Double {
        return rotationAngle / amplitude
    }
    
    func describe() -> String {
        let string1 = "Pulse duration = \(duration) μs"
        let string2 = "Flip angle = \(flipAngle)˚"
        let string3 = "ɷ₁/2π = \(amplitude) kHz"
        return string1 + "\n" + string2 + "\n" + string3
    }
    
}
