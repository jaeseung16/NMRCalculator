//
//  NMRPulse.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRPulse {
    var duration = 0.0 // pulse duration in μs
    var flipangle = 0.0 // flip angle in degree
    public var amplitude = 0.0 // RF amplitude in kHz
    var offset = 0.0 // frequency offset in Hz
    
    enum parameters: String {
        case duration
        case flipangle
        case amplitude
        case offset
    }
    
    init() {
        
    }
    
    mutating func setParameter(parameter name: String, to value: Double) -> Bool {
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .amplitude:
            self.amplitude = value
        case .duration:
            guard value >= 0 else { return false }
            self.duration = value
        case .flipangle:
            self.flipangle = value
        case .offset:
            self.offset = value
        }
        
        return true
    }
    
    mutating func updateParameter(name: String) -> Bool {
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .duration:
            guard (self.amplitude != 0) else { return false }
            self.duration = ( self.flipangle / self.amplitude ) * ( 1000.0 / 360.0 )
            
        case .amplitude:
            guard (self.duration != 0) else { return false }
            self.amplitude = ( self.flipangle / self.duration ) * ( 1000.0 / 360.0 )
            
        case .flipangle:
            self.flipangle = ( self.duration * self.amplitude ) * ( 360.0 / 1000.0 )
            
        case .offset:
            break
        }
        
        return true
    }
    
    func describe() -> String {
        let string1 = "Pulse duration = \(self.duration) μs"
        let string2 = "Flip angle = \(self.flipangle)˚"
        let string3 = "ɷ₁/2π = \(self.amplitude) kHz"
        let string4 = "Frequency offset = \(self.offset) Hz"
        
        return string1 + "\n" + string2 + "\n" + string3 + "\n" + string4
    }
    
}
