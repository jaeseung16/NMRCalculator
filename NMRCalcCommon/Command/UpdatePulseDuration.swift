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
    let pulse: Pulse
    
    init(_ pulse: Pulse) {
        self.pulse = pulse
    }
    
    func execute(with value: Double) {
        pulse.set(duration: value)
    }
}
