//
//  ErnstAngleCalculator.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

// TODO: - A class with the same name exists in NMRCalc (for Mac)
class ErnstAngleCalculator {
    private let radianToDegree = 180.0 / Double.pi
    private var degreeToRadian: Double {
        return 1.0 / radianToDegree
    }
    
    func calculateErnstAngle(repetitionTime: Double, relaxationTime: Double) -> Double {
        return acos( exp(-1.0 * repetitionTime / relaxationTime) ) * radianToDegree
    }
    
    func calculateRepetitionTime(ernstAngle: Double, relaxationTime: Double) -> Double {
        return -1.0 * relaxationTime * log(cos(ernstAngle * degreeToRadian))
    }
}
