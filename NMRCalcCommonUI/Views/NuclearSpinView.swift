//
//  WatchNuclearSpinView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/15/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI
import NMRCalculatorCommon

struct NuclearSpinView: View {
    let slash = "/"
    let nucleus: NMRNucleus
    
    var fraction: Fraction {
        var numerator: UInt
        var denominator: UInt = 1

        if (Fraction.isFraction(nucleus.nuclearSpin)) {
            (numerator, denominator) = Fraction.getNumeratorAndDenominator(nucleus.nuclearSpin)
        } else {
            numerator = UInt(nucleus.nuclearSpin)!
        }

        return Fraction(positive: true,
                        numerator: numerator,
                        denominator: denominator)
    }
    
    var body: some View {
        Text(fraction.inlineDescription)
            .font(.body)
    }
}
