//
//  UpdateRepetitionTime.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/10/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import NMRCalculatorCommon

class UpdateRepetitionTime: NMRCalcCommand {
    let ernstAngleCalculator: ErnstAngleConverter
    
    init(_ ernstAngleCalculator: ErnstAngleConverter) {
        self.ernstAngleCalculator = ernstAngleCalculator
    }
    
    func execute(with value: Double) {
        ernstAngleCalculator.set(repetitionTime: value)
    }
}
