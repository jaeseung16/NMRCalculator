//
//  WatchNucleusDetailView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/14/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusDetailView: View {
    @EnvironmentObject var userData: UserData
    @State private var changingProtonFrequency = true
    
    var nucleus: NMRNucleus
    
    private var externalField: Double
    {
        return self.userData.scrollAmount * 10.0
    }
    private var protonFrequency: Double
    {
        return self.userData.scrollAmount * 10.0 * UserData().nuclei[0].γ
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .trailing, spacing: 0) {
                HStack(alignment: .center) {
                    WatchAtomicElementView(
                        elementSymbol: self.nucleus.symbolNucleus,
                        massNumber: UInt(self.nucleus.atomicWeight)!)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(self.nucleus.nuclearSpin)")
                        .font(.body)
                        
                        Text("\(self.nucleus.naturalAbundance)")
                        .font(.body)
                    }
                    .padding(.trailing, 8)
                }
                .background(Color.green)
            
               
                LarmorFrequencyView(externalField: self.externalField,
                                    gyromatneticRatio: self.nucleus.γ)
                    .focusable(true) { _ in
                        self.changingProtonFrequency = false
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 8))
                .digitalCrownRotation(self.$userData.scrollAmount, from: 0.0, through: 10.0, by: 0.005, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                .frame(width: geometry.size.width)
                .border(Color.white, width: self.changingProtonFrequency ? 0 : 2)
                
                
                ProtonFrequencyView(protonFrquency: self.protonFrequency)
                    .focusable(true) { _ in
                        self.changingProtonFrequency = true
                }
                .digitalCrownRotation(self.$userData.scrollAmount, from: 0.0, through: 10.0, by: 0.0001, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 8))
                .frame(width: geometry.size.width)
                .border(Color.white, width: self.changingProtonFrequency ? 2 : 0)
            }
            .frame(width: geometry.size.width)
            .background(Color.secondary)
        }
    }
}

struct WatchNucleusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return WatchNucleusDetailView(nucleus: UserData().nuclei[1])
            .environmentObject(UserData())
    }
}
