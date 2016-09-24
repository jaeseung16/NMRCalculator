//
//  NMRfid.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRfid {
    
    var size: UInt? // number of data points
    var duration: Double? // duration in ms
    var dwell: Double? // dwell time in μs
    var real: [Double] // real part
    var imag: [Double] // imaginary part
    
    enum parameters: String {
        case size
        case duration
        case dwell
    }
    
    init() {
        size = UInt()
        duration = Double()
        dwell = Double()
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
            case .duration:
                if to_value > 0 {
                    duration = to_value
                    return true
                }
            case .dwell:
                if to_value > 0 {
                    dwell = to_value
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
                if duration != nil && dwell != nil {
                    size = UInt( 1000.0 * duration! / dwell! )
                    return true
                }

            case .duration:
                if size != nil && dwell != nil {
                    duration = Double(size!) * dwell! / 1000.0
                    return true
                }

            case .dwell:
                if size != nil && duration != nil {
                    dwell = duration! / Double(size!) * 1000.0
                    return true
                }

            }
            
        }
        
        return false
    }
    
}
