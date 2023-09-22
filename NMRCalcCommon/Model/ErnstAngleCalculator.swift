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
    private static let radianToDegree = 180.0 / Double.pi
    private static var degreeToRadian: Double {
        return 1.0 / radianToDegree
    }
    
    public static func calculateErnstAngle(repetitionTime: Double, relaxationTime: Double) -> Double {
        return acos( exp(-1.0 * repetitionTime / relaxationTime) ) * radianToDegree
    }
    
    public static func calculateRepetitionTime(ernstAngle: Double, relaxationTime: Double) -> Double {
        return -1.0 * relaxationTime * log(cos(ernstAngle * degreeToRadian))
    }

    public var ernstAngle: Double // degree
    public var repetitionTime: Double // sec
    public var relaxationTime: Double // sec
    
    public init(repetitionTime: Double, relaxationTime: Double) {
        self.repetitionTime = repetitionTime
        self.relaxationTime = relaxationTime
        self.ernstAngle = ErnstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
    }
    
    public func set(repetitionTime: Double) {
        self.repetitionTime = repetitionTime
        ernstAngle = ErnstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
    }
    
    public func set(relaxationTime: Double) {
        self.relaxationTime = relaxationTime
        ernstAngle = ErnstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
    }
    
    public func set(ernstAngle: Double) {
        self.ernstAngle = ernstAngle
        repetitionTime = ErnstAngleCalculator.calculateRepetitionTime(ernstAngle: ernstAngle, relaxationTime: relaxationTime)
    }
    
}
