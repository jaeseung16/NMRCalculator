//
//  NMRPulse.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRPulse {
    var duration: Double? // pulse duration in μs
    var flipangle: Double? // flip angle in degree
    var amplitude: Double? // RF amplitude in kHz
    var offset: Double? // frequency offset in Hz
    
    enum parameters: String {
        case duration
        case flipangle
        case amplitude
        case offset
    }
    
    init() {
        duration = Double()
        flipangle = Double()
        amplitude = Double()
        offset = 0.0
    }
    
    convenience init(μs: Double) {
        self.init()
        self.duration = μs
    }
    
    convenience init(degree: Double) {
        self.init()
        self.flipangle = degree
    }
    
    convenience init(kHz: Double) {
        self.init()
        self.amplitude = kHz
    }
    
    convenience init(degree: Double, μs: Double) {
        self.init()
        self.flipangle = degree
        self.duration = μs
        if update(name: "amplitude") == false {
            print("Initialization failed.")
        }
    }
    
    convenience init(degree: Double, kHz: Double) {
        self.init()
        self.flipangle = degree
        self.amplitude = kHz
        if update(name: "duration") == false {
            print("Initialization failed.")
        }
    }
    
    convenience init(μs: Double, kHz: Double) {
        self.init()
        self.duration = μs
        self.amplitude = kHz
        if update(name: "flipangle") == false {
            print("Initialization failed.")
        }
    }
    
    func set_parameter(name: String, to_value: Double) -> Bool {
        if let to_set = parameters(rawValue: name) {
            switch to_set {
            case .amplitude:
                if to_value != 0 {
                    amplitude = to_value
                }
                return true
            case .duration:
                if to_value > 0 {
                    duration = to_value
                }
                return true
            case .flipangle:
                flipangle = to_value
                return true
            case .offset:
                offset = to_value
                return true
            }
        }
        
        return false
        
    }
    
    // ToDo: When the sign of the filpangle changes, keep the duration being positive and change the sign of the amplitude !
    // ToDo: Likewise, when the sign of the amplitude changes, keep the duration being positive and change the signe of the flipangle!
    
    func update(name: String) -> Bool {
        
        if let to_update = parameters(rawValue: name) {
            switch to_update {
            case .duration:
                if flipangle != nil && amplitude != nil {
                    duration = ( flipangle! / amplitude! ) * ( 1000.0 / 360.0 )
                    return true
                }
            case .amplitude:
                if flipangle != nil && duration != nil {
                    amplitude = ( flipangle! / duration! ) * ( 1000.0 / 360.0 )
                    return true
                }
            case .flipangle:
                if duration != nil && amplitude != nil {
                    flipangle = ( duration! * amplitude! ) * ( 360.0 / 1000.0 )
                    return true
                }
            case .offset:
                    return true
            }
        }

        return false
    }
}
