//
//  ErnstAngleCalculator.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class ErnstAngleCalculator {
    static let shared = ErnstAngleCalculator()
    
    private let radianToDegree = 180.0 / Double.pi
    private var degreeToRadian: Double {
        return 1.0 / radianToDegree
    }
    
    func calculateErnstAngle(repetitionTime: Double, relaxationTime: Double) -> Double {
        return acos( exp(-1.0 * repetitionTime / relaxationTime) ) * radianToDegree
    }
    
    func calculateRepetitionTime(relaxationTime: Double, ernstAngle: Double) -> Double {
        return -1.0 * relaxationTime * log(cos(ernstAngle * degreeToRadian))
    }
}
