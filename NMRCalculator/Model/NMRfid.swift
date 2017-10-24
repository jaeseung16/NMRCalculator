//
//  NMRfid.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRfid {
    
    var size: UInt = 1000 // number of data points
    var duration: Double = 10.0 // duration in ms
    var dwell: Double = 10.0 // dwell time in μs
    //    var real: [Double] // real part
    //    var imag: [Double] // imaginary part
    
    enum parameters: String {
        case size
        case duration
        case dwell
    }
    
    init() {
        
    }
    
    mutating func setFID(parameter name: String, to value: Double) -> Bool {
        
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard ( value <= Double( UInt.max ) ) && ( value > Double( UInt.min ) ) else { return false }
            self.size = UInt(value)
            
        case .duration:
            guard value > 0 else { return false }
            self.duration = value
            
        case .dwell:
            guard value > 0 else { return false }
            self.dwell = value
        }
        
        return true
        
    }
    
    mutating func updateParameters(name: String) -> Bool {
        
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard self.dwell > 0 else { return false }
            self.size = UInt( 1000.0 * self.duration / self.dwell )
            
        case .duration:
            self.duration = Double(self.size) * self.dwell / 1000.0
            
        case .dwell:
            guard self.size > 0 else { return false }
            self.dwell = 1000.0 * self.duration / Double(self.size)
            
        }
        
        return true
    }
    
    func describe() -> String {
        let string1 = "FID size = \(self.size)"
        
        let string2 = "FID duration = \(self.duration) ms"
        
        let string3 = "Dwell time = \(self.dwell) μs"
        
        return string1 + "\n" + string2 + "\n" + string3
    }
    
}