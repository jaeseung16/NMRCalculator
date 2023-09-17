//
//  NucleusView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NucleusInfoView: View {
    var nucleus: NMRNucleus
    
    private var nuclearSpin: String {
        Fraction(from: nucleus.nuclearSpin, isPositive: nucleus.γ > 0).inlineDescription
    }
    
    var body: some View {
        HStack {
            AtomicElementView(elementSymbol: nucleus.symbolNucleus,
                              massNumber: UInt(nucleus.atomicWeight)!)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                getInfoView(title: NMRCalcConstants.naturalAbundance,
                            value: nucleus.naturalAbundance)
                getInfoView(title: NMRCalcConstants.nuclearSpin,
                            value: nuclearSpin)
            }
        }
    }
    
    private func getInfoView(title: String, value: String) -> some View {
        HStack {
            Spacer()
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.secondary)
            
            Text(value)
                .font(.body)
                .foregroundColor(Color.primary)
        }
    }
}
