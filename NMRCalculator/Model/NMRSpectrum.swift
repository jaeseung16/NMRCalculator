//
//  NMRSpectrum.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRSpectrum {
    // MARK: Properties
    var size: UInt = 1000 // number of data points
    var width: Double = 1.0 // spectral width in kHz
    var resolution: Double // spectral resolution in Hz
    
    enum Parameters: String {
        case size
        case width
        case resolution
    }
    
    // MARK: Methods
    init() {
        resolution = 1000.0 * width / Double(size)
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard ( value <= Double( UInt.max ) ) && ( value > Double( UInt.min ) ) else { return false }
            size = UInt(value)
            
        case .width:
            guard value > 0 else { return false }
            width = value
            
        case .resolution:
            guard value > 0 else { return false }
            resolution = value
        }
        
        return true
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard self.resolution > 0 else { return false }
            size = UInt( 1000.0 * width / resolution )
            
        case .width:
            width = Double(size) * resolution / 1000.0
            
        case .resolution:
            guard self.size > 0 else { return false }
            resolution = 1000.0 * width / Double(size)
        }
        
        return true
    }
    
    func describe() -> String {
        let string1 = "Size = \(size)"
        let string2 = "Width = \(width) kHz"
        let string3 = "Resolution = \(resolution) Hz"
        return string1 + "\n" + string2 + "\n" + string3
    }
}
