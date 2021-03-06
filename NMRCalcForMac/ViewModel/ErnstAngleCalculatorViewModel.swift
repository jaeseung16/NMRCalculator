//
//  MacNMRErnstAngleCalculator.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Foundation

class ErnstAngleCalculatorViewModel: ObservableObject {
    @Published var repetitionTime: Double?
    @Published var relaxationTime: Double?
    @Published var ernstAngle: Double?
    
    private let radianToDegree = 180.0 / Double.pi
    private var degreeToRadian: Double {
        return 1.0 / radianToDegree
    }
    
    private func updateErnstAngle(repetitionTime: Double, relaxationTime: Double) -> Double {
        return acos( exp(-1.0 * repetitionTime / relaxationTime) ) * radianToDegree
    }
    
    func repetitionTimeUpdated() -> Void {
        if relaxationTime == nil {
            relaxationTime = 1.0
        }
        
        if repetitionTime == nil {
            repetitionTime = 1.0
        }
        
        ernstAngle = updateErnstAngle(repetitionTime: repetitionTime!, relaxationTime: relaxationTime!)
    }
    
    func relaxationTimeUpdated() -> Void {
        if relaxationTime == nil {
            relaxationTime = 1.0
        }
        
        if repetitionTime == nil {
            repetitionTime = 1.0
        }
        
        ernstAngle = updateErnstAngle(repetitionTime: repetitionTime!, relaxationTime: relaxationTime!)
    }
    
    func ernstAngleUpdated() -> Void {
        if relaxationTime == nil {
            relaxationTime = 1.0
        }
        
        repetitionTime = -1.0 * relaxationTime! * log(cos(ernstAngle! * degreeToRadian))
    }
}
