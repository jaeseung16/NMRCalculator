//
//  NMRSpectrum.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRSpectrum {
    var size: UInt? // number of data points
    var width: Double? // spectral width in kHz
    var resolution: Double? // spectral resolution in Hz
    var real: [Double] // real part
    var imag: [Double] // imaginary part
    
    enum parameters: String {
        case size
        case width
        case resolution
    }
    
    init() {
        size = UInt()
        width = Double()
        resolution = Double()
        real = [Double]()
        imag = [Double]()
    }
    
    func set_parameter(_ name: String, to_value: Double) -> Bool {
        if let to_set = parameters(rawValue: name) {
            switch to_set {
            case .size:
                if to_value <= Double( UInt.max ) && to_value > Double( UInt.min ) {
                    size = UInt(to_value)
                    return true
                }
            case .width:
                if to_value > 0 {
                    width = to_value
                    return true
                }
            case .resolution:
                if to_value > 0 {
                    resolution = to_value
                    return true
                }
            }
        }
        
        return false
        
    }
    
    func update(_ name: String) -> Bool {
        if let to_update = parameters(rawValue: name) {
            switch to_update {
            case .size:
                if width != nil && resolution != nil {
                    size = UInt( 1000.0 * width! / resolution! )
                        return true
                }
            case .width:
                if size != nil && resolution != nil {
                    width = Double(size!) * resolution! / 1000.0
                    return true
                }
            case .resolution:
                if size != nil && width != nil {
                    resolution = 1000.0 * width! / Double(size!)
                    return true
                }
            }
        }
        
        return false
    }
}
