//
//  CalculateLarmorFrequencyCommand.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/5/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class UpdateLarmorFrequency: NMRCalcCommand {
    
    let larmorFrequencyCalculator: LarmorFrequencyMagneticFieldConverter
    
    init(_ larmorFrequencyCalculator: LarmorFrequencyMagneticFieldConverter) {
        self.larmorFrequencyCalculator = larmorFrequencyCalculator
    }
    
    func execute(with value: Double) -> Void {
        larmorFrequencyCalculator.set(larmorFrequency: value)
    }
    
}
