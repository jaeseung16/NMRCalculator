//
//  MacNucleusView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusView: View {
    @EnvironmentObject var userData: UserData
    var nucleus: NMRNucleus
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                WatchAtomicElementView(
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

struct MacNucleusView_Previews: PreviewProvider {
    static var previews: some View {
        MacNucleusView(nucleus: UserData().nuclei[9])
    }
}
