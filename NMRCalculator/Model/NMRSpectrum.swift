//
//  NMRSpectrum.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRSpectrum {
    var size: UInt = 1000 // number of data points
    var width: Double = 1.0 // spectral width in kHz
    var resolution: Double = 1.0 // spectral resolution in Hz
    //    var real: [Double] // real part
    //    var imag: [Double] // imaginary part
    
    enum parameters: String {
        case size
        case width
        case resolution
    }
    
    init() {
        
    }
    
    mutating func setSpectrum(parameter name: String, to value: Double) -> Bool {
        
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard ( value <= Double( UInt.max ) ) && ( value > Double( UInt.min ) ) else { return false }
            self.size = UInt(value)
            
        case .width:
            guard value > 0 else { return false }
            self.width = value
            
        case .resolution:
            guard value > 0 else { return false }
            self.resolution = value
        }
        
        return true
        
    }
    
    mutating func updateParameter(name: String) -> Bool {
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard self.resolution > 0 else { return false }
            self.size = UInt( 1000.0 * self.width / self.resolution )
            
        case .width:
            self.width = Double(self.size) * self.resolution / 1000.0
            
        case .resolution:
            guard self.size > 0 else { return false }
            self.resolution = 1000.0 * self.width / Double(self.size)
        }
        
        return true
    }
    
    func describe() -> String {
        let string1 = "Spectrum size = \(self.size)"
        
        let string2 = "Spectral width = \(self.width) kHz"
        
        let string3 = "Resolution = \(self.resolution) Hz"
        
        return string1 + "\n" + string2 + "\n" + string3
    }
}
