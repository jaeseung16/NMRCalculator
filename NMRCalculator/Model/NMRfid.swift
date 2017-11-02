//
//  NMRfid.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRfid {
    // MARK: Properties
    var size: UInt = 1000 // number of data points
    var duration: Double = 10.0 // duration in ms
    var dwell: Double // dwell time in μs
    
    enum Parameters: String {
        case size
        case duration
        case dwell
    }
    
    // MARK: - Methods
    init() {
        dwell = 1000.0 * duration / Double(size)
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard ( value <= Double( UInt.max ) ) && ( value > Double( UInt.min ) ) else { return false }
            size = UInt(value)
            
        case .duration:
            guard value > 0 else { return false }
            duration = value
            
        case .dwell:
            guard value > 0 else { return false }
            dwell = value
        }
        
        return true
        
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard dwell > 0 else { return false }
            size = UInt( 1000.0 * duration / dwell )
            
        case .duration:
            duration = Double(size) * dwell / 1000.0
            
        case .dwell:
            guard self.size > 0 else { return false }
            dwell = 1000.0 * duration / Double(size)
        }
        
        return true
    }
    
    func describe() -> String {
        let string1 = "FID size = \(size)"
        let string2 = "FID duration = \(duration) ms"
        let string3 = "Dwell time = \(dwell) μs"
        return string1 + "\n" + string2 + "\n" + string3
    }
    
}
