//
//  NMRErnstAngle.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 11/1/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRErnstAngle {
    // MARK: Properties
    var repetitionTime: Double = 1.0 // Repetition Time (TR) in sec
    var relaxationTime: Double = 1.0 // Logitudinal Relaxation Time (T1) in sec
    var angleErnst: Double
    
    enum Parameters: String {
        case repetition
        case relaxation
        case angleErnst
    }
    
    // MARK: - Methods
    init() {
        angleErnst = acos( exp(-1.0 * repetitionTime / relaxationTime) )
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .repetition:
            repetitionTime = value
        case .relaxation:
            relaxationTime = value
        case .angleErnst:
            angleErnst = value
        }
        
        return true
    }
    
    mutating func update(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .repetition:
            repetitionTime = -1.0 * relaxationTime * log( cos(angleErnst) )
        case .relaxation:
            relaxationTime = -1.0 * repetitionTime / log( cos(angleErnst) )
        case .angleErnst:
            angleErnst = acos( exp(-1.0 * repetitionTime / relaxationTime) )
        }
        return true
    }
    
    func describe() -> String {
        let string1 = "Repetition Time = \(repetitionTime) sec"
        let string2 = "Relaxation Time = \(relaxationTime) sec"
        let string3 = "Ernst Angle = \(angleErnst * 180.0 / Double.pi)˚"
        return string1 + "\n" + string2 + "\n" + string3
    }
}
