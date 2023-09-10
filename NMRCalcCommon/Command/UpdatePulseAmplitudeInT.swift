//
//  UpdatePulseAmplitudeInT.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation

class UpdatePulseAmplitudeInT: NMRCalcCommand {
    let pulse: Pulse
    
    init(_ pulse: Pulse) {
        self.pulse = pulse
    }
    
    func execute(with value: Double) {
        
    }
}
