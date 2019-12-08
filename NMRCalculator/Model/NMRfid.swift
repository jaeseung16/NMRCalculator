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
    let msToμs: Double = 1000.0
    var μsToMs: Double {
        get {
            return 1.0 / msToμs
        }
    }
    
    var size: UInt = 1000 // number of data points
    var duration: Double = 10.0 // duration in ms
    var dwell: Double // dwell time in μs
    
    enum Parameter: String {
        case size
        case duration
        case dwell
    }
    
    // MARK: - Methods
    init() {
        dwell = (duration * msToμs) / Double(size)
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            guard canConvertToUInt(value) else { return false }
            size = UInt(value)
        case .duration:
            guard isPositive(value) else { return false }
            duration = value
        case .dwell:
            guard isPositive(value) else { return false }
            dwell = value
        }
        return true
    }
    
    private func canConvertToUInt(_ value: Double) -> Bool {
        return (value <= Double(UInt.max)) && (value > Double(UInt.min))
    }
    
    private func isPositive(_ value: Double) -> Bool {
        return value > 0
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .size:
            calculateSize()
        case .duration:
            calculateDuration()
        case .dwell:
            calculateDwell()
        }
        return true
    }
    
    mutating private func calculateSize() {
        size = UInt( (duration * msToμs) / dwell )
    }
    
    mutating private func calculateDuration() {
        duration = Double(size) * (dwell * μsToMs)
    }
    
    mutating private func calculateDwell() {
        dwell = (duration * msToμs) / Double(size)
    }
    
    func describe() -> String {
        let string1 = "FID size = \(size)"
        let string2 = "FID duration = \(duration) ms"
        let string3 = "Dwell time = \(dwell) μs"
        return string1 + "\n" + string2 + "\n" + string3
    }
}
