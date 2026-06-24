//
//  UpdatePulseAmplitudeInT.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation
import NMRCalculatorCommon

class UpdatePulseAmplitudeInT: NMRCalcCommand {
    let pulseParameterConverter: PulseParameterConverter
    
    init(_ pulseParameterConverter: PulseParameterConverter) {
        self.pulseParameterConverter = pulseParameterConverter
    }
    
    func execute(with value: Double) {
        pulseParameterConverter.set(amplitudeInT: value)
    }
}
