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
                    getInfoView(
                        title: "Nuclear Spin",
                        value: Fraction(from: nucleus.nuclearSpin, isPositive: nucleus.γ > 0).inlineDescription
                    )
                    
                    getInfoView(
                        title: "MHz/T",
                        value: "\(String(format: "%.4f", abs(nucleus.γ)))"
                    )
                    
                    getInfoView(
                        title: "NA",
                        value: nucleus.naturalAbundance
                    )
                }
                .scaledToFill()
            }
            .frame(width: geometry.size.width)
        }
    }
    
    private func getInfoView(title: String, value: String) -> some View {
        VStack(alignment: .trailing) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.secondary)
            
            Text(value)
                .font(.body)
                .foregroundColor(Color.primary)
                .fontWeight(.semibold)
        }
    }
}

struct MacNucleusView_Previews: PreviewProvider {
    static var previews: some View {
        MacNucleusView(nucleus: UserData().nuclei[9])
    }
}
