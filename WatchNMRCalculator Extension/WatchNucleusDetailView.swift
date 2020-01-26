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
                        WatchNuclearSpinView(nucleus: self.nucleus)
                            .font(.body)
                                              
                        Text("\(self.nucleus.naturalAbundance)")
                            .font(.body)
                    }
                    .padding(.trailing, 8)
                }
                .foregroundColor(.green)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                //.background(Color.green)
                
                LarmorFrequencyView(externalField: self.externalField,
                                    gyromatneticRatio: self.nucleus.γ)
                    .foregroundColor(self.changingProtonFrequency ? .secondary : .primary)
                    .focusable(true) { _ in
                        self.changingProtonFrequency = false
                    }
                .digitalCrownRotation(self.$userData.scrollAmount, from: 0.0, through: 10.0, by: 0.00001, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                
                ProtonFrequencyView(protonFrquency: self.protonFrequency)
                    .foregroundColor(self.changingProtonFrequency ? .primary : .secondary)
                    .focusable(true) { _ in
                        self.changingProtonFrequency = true
                    }
                    .digitalCrownRotation(self.$userData.scrollAmount, from: 0.0, through: 10.0, by: 0.0000001, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
    }
}

struct WatchNucleusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return WatchNucleusDetailView(nucleus: UserData().nuclei[3])
            .environmentObject(UserData())
    }
}
