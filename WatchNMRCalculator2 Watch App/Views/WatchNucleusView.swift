//
//  WatchNucleusView.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/13/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusView: View {
    var nucleus: NMRNucleus
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                AtomicElementView(elementSymbol: nucleus.symbolNucleus, massNumber: UInt(nucleus.atomicWeight)!)
                    .scaledToFill()
                    .frame(width: geometry.size.width * 0.35)
                    .foregroundColor(Color.green)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    WatchNucleusInfoView(title: WatchNMRCalculatorConstant.nuclearSpin.rawValue,
                                         item: Fraction(from: nucleus.nuclearSpin, isPositive: nucleus.γ > 0).inlineDescription)
                    WatchNucleusInfoView(title: WatchNMRCalculatorConstant.megahertzPerTesla.rawValue,
                                         item: "\(String(format: "%.2f", abs(nucleus.γ)))")
                    WatchNucleusInfoView(title: WatchNMRCalculatorConstant.naturalAbundance.rawValue,
                                         item: nucleus.naturalAbundance)
                }
                .scaledToFill()
            }
            .frame(width: geometry.size.width)
        }
    }
}
