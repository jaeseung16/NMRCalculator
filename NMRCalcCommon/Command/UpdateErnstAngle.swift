//
//  UpdateRelativePower.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/10/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import NMRCalculatorCommon

class UpdateErnstAngle: NMRCalcCommand {
    let ernstAngleCalculator: ErnstAngleCalculator
    
    init(_ ernstAngleCalculator: ErnstAngleCalculator) {
        self.ernstAngleCalculator = ernstAngleCalculator
    }
    
    func execute(with value: Double) {
        ernstAngleCalculator.set(ernstAngle: value)
    }

}
