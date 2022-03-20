//
//  LarmorFrequencyCalculator.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/20/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class LarmorFrequencyCalculator {
    static let shared = LarmorFrequencyCalculator()
    
    let γProton = NMRCalcConstants.gammaProton
    let γElectron = NMRCalcConstants.gammaElectron
    
    func ω(γ: Double, B: Double) -> Double {
        return γ * B
    }
    
    func ωProton(at B: Double) -> Double {
        return ω(γ: γProton, B: B)
    }
    
    func ωElectron(at B: Double) -> Double {
        return ω(γ: γElectron, B: B)
    }
    
}
