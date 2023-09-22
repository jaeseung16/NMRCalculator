//
//  UpdateSpectralWidthInKHz.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/10/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class UpdateSpectralWidthInkHz: NMRCalcCommand {
    let frequencyDomainCalculator: SpectralWidthFrequencyResolutionConverter
    
    init(_ frequencyDomainCalculator: SpectralWidthFrequencyResolutionConverter) {
        self.frequencyDomainCalculator = frequencyDomainCalculator
    }
    
    func execute(with value: Double) {
        frequencyDomainCalculator.set(spectralWidthInkHz: value)
    }
}
