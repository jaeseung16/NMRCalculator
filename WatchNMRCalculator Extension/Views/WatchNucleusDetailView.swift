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
    @State var scrollAmountToFieldFactor: Double = 1
    
    var nucleus: NMRNucleus
    
    private var externalField: Double
    {
        return self.userData.focus == .ExternalField ? self.userData.scrollAmount  : self.userData.scrollAmount / UserData.γProton
    }
    private var protonFrequency: Double
    {
        return self.userData.focus == .ProtonFrequency ? self.userData.scrollAmount : self.userData.scrollAmount * UserData.γProton
    }
    
    private let minValue = 0.0
    private var maxValue: Double {
        return self.userData.focus == .ExternalField ? 100 : 2000
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
                    .foregroundColor(self.userData.focus == .ProtonFrequency ? .secondary : .primary)
                    .focusable(true) { _ in
                        if (self.userData.focus == .ProtonFrequency) {
                            self.userData.focus = .ExternalField
                            self.userData.scrollAmount /= UserData.γProton
                        }
//                        self.switchFocus()
                    }
                .digitalCrownRotation(self.$userData.scrollAmount, from: self.minValue, through: self.maxValue, by: 0.01, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                
                ProtonFrequencyView(protonFrquency: self.protonFrequency)
                    .foregroundColor(self.userData.focus == .ProtonFrequency ? .primary : .secondary)
                    .focusable(true) { _ in
                        if (self.userData.focus == .ExternalField) {
                            self.userData.focus = .ProtonFrequency
                            self.userData.scrollAmount *= UserData.γProton
                        }
                        //self.switchFocus()
                    }
                    .digitalCrownRotation(self.$userData.scrollAmount, from: self.minValue, through: self.maxValue, by: 0.01, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
    }
    
    // Why this is not working?
//    private func switchFocus() {
//        switch self.userData.focus {
//        case .ExternalField:
//            self.userData.focus = .ProtonFrequency
//            self.userData.scrollAmount *= UserData.γProton
//        case .ProtonFrequency:
//            self.userData.focus = .ExternalField
//            self.userData.scrollAmount /= UserData.γProton
//        }
//    }
}

struct WatchNucleusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return WatchNucleusDetailView(nucleus: UserData().nuclei[3])
            .environmentObject(UserData())
    }
}
