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

        if (Fraction.isFraction(nucleus.nuclearSpin)) {
            (numerator, denominator) = Fraction.getNumeratorAndDenominator(nucleus.nuclearSpin)
        } else {
            numerator = UInt(nucleus.nuclearSpin)!
        }

        return Fraction(positive: isPositive,
                        numerator: numerator,
                        denominator: denominator)
    }
    
    var body: some View {
        Text(fraction.inlineDescription)
            .font(.body)
    }
}

struct WatchNuclearSpinView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNuclearSpinView(nucleus: UserData().nuclei[6])
    }
}
