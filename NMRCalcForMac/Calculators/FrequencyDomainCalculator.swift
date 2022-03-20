//
//  FrequencyDomainCalculator.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class FrequencyDomainCalculator {
    static let shared = FrequencyDomainCalculator()
    
    let kHzToHz: Double = 1000.0
    

    func calculateFrequencyResolution(spectralWidth: Double, numberOfDataPoints: Double) -> Double {
        return spectralWidth * kHzToHz / numberOfDataPoints
    }
    
    func calcualteNumberOfDataPoints(spectralWidth: Double, frequencyResolution: Double) -> Double {
        return spectralWidth * kHzToHz / frequencyResolution
    }
    
}
