//
//  NMRCalcConst.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 10/13/18.
//  Copyright © 2018 Jae-Seung Lee. All rights reserved.
//

import Foundation

extension NMRCalc {
    enum Category: String {
        case resonance
        case acquisition
        case spectrum
        case pulse1
        case pulse2
        case ernstAngle
    }
    enum Ernst: String {
        case repetition
        case relaxation
        case angle
    }
    
}
