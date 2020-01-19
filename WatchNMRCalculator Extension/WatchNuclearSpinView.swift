//
//  WatchNuclearSpinView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/15/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNuclearSpinView: View {
    let slash = "/"
    
    let nucleus: NMRNucleus
    
    var fraction: Fraction {
        let isPositive = nucleus.γ > 0
        var numerator: UInt
        var denominator: UInt = 1

        if (isFraction(nucleus.nuclearSpin)) {
            (numerator, denominator) = getNumeratorAndDenominator(nucleus.nuclearSpin)
            
        } else {
            numerator = UInt(nucleus.nuclearSpin)!
        }

        return Fraction(positive: isPositive,
                        numerator: numerator,
                        denominator: denominator)
    }
    
    var body: some View {
        Text(fraction.presentWithSlash())
            .font(.body)
    }
    
    private func isFraction(_ fraction: String) -> Bool {
        return fraction.contains(slash)
    }
    
    private func getNumeratorAndDenominator(_ fraction: String) -> (UInt, UInt) {
        var numerator: UInt
        var denominator: UInt = 1
        let invalidValue: UInt = UInt.max
        
        let fractionString = nucleus.nuclearSpin
            .split(separator: Character(slash))
            .map {substring in String(substring)}
        
        if (fractionString.count == 2) {
            numerator = UInt(fractionString[0])!
            denominator = UInt(fractionString[1])!
        } else {
            numerator = invalidValue
        }
        
        return (numerator, denominator)
    }
}

struct WatchNuclearSpinView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNuclearSpinView(nucleus: UserData().nuclei[6])
    }
}
