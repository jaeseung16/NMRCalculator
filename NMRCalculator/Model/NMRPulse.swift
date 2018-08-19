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
    var flipangle: Double = 90.0 // flip angle in degree
    var amplitude: Double // RF amplitude in kHz
    
    enum Parameter: String {
        case duration
        case flipangle
        case amplitude
    }
    
    // MARK:- Methods
    init() {
        amplitude = ( flipangle / duration ) * ( 1000.0 / 360.0 )
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .amplitude:
            amplitude = value
            
        case .duration:
            guard value >= 0 else { return false }
            duration = value
            
        case .flipangle:
            flipangle = value
        }
        
        return true
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .duration:
            guard (amplitude != 0) else { return false }
            duration = ( flipangle / amplitude ) * ( 1000.0 / 360.0 )
            
        case .amplitude:
            guard (duration != 0) else { return false }
            amplitude = ( flipangle / duration ) * ( 1000.0 / 360.0 )
            
        case .flipangle:
            flipangle = ( duration * amplitude ) * ( 360.0 / 1000.0 )
        }
        
        return true
    }
    
    func describe() -> String {
        let string1 = "Pulse duration = \(duration) μs"
        let string2 = "Flip angle = \(flipangle)˚"
        let string3 = "ɷ₁/2π = \(amplitude) kHz"
        return string1 + "\n" + string2 + "\n" + string3
    }
    
}
