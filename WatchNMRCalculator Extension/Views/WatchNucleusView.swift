//
//  WatchNucleusView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusView: View {
    @EnvironmentObject var userData: NMRPeriodicTableData
    var nucleus: NMRNucleus
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                AtomicElementView(
                    elementSymbol: self.nucleus.symbolNucleus,
                    massNumber: UInt(self.nucleus.atomicWeight)!)
                    .scaledToFill()
                    .frame(width: geometry.size.width * 0.35)
                    .foregroundColor(Color.green)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    WatchNucleusInfoView(title: "Nuclear Spin",
                                         item: Fraction(from: self.nucleus.nuclearSpin, isPositive: self.nucleus.γ > 0).inlineDescription)
                    
                    WatchNucleusInfoView(title: "MHz/T",
                                         item: "\(String(format: "%.2f", abs(self.nucleus.γ)))")
                    
                    WatchNucleusInfoView(title: "NA",
                                         item: self.nucleus.naturalAbundance)
                }
                .scaledToFill()
            }
            .frame(width: geometry.size.width)
        }
    }
}

struct WatchNucleusView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNucleusView(nucleus: NMRPeriodicTableData().nuclei[9])
    }
}
