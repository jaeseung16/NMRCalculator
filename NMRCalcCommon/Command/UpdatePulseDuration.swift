//
//  UpdatePulseDuration.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/10/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import NMRCalculatorCommon

class UpdatePulseDuration: NMRCalcCommand {
    let pulseParameterConverter: PulseParameterConverter
    
    init(_ pulseParameterConverter: PulseParameterConverter) {
        self.pulseParameterConverter = pulseParameterConverter
    }
    
    func execute(with value: Double) {
        pulseParameterConverter.set(duration: value)
    }
}
