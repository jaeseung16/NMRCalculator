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
    
    var nucleus: NMRNucleus
    var externalField: Double = 2
    
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
            
                HStack(alignment: .top) {
                    Text(String(format: "%.4f", self.userData.scrollAmount * self.nucleus.γ))
                        .font(.headline)
                    +
                    Text(" MHz")
                        .font(.body)
                }
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 24))
                
                HStack(alignment: .top, spacing: 0) {
                    Text("@ ")
                    Text(String(format: "%.3f", Double(self.userData.scrollAmount)))
                        .focusable(true)
                        .digitalCrownRotation(self.$userData.scrollAmount, from: 0.0, through: 100.0, by: 0.02, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                        .font(.headline)
                    Text(" T")
                        .font(.body)
                }
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Proton").font(.caption)
                    
                    Text(String(format: "%6.4f", self.userData.scrollAmount * UserData().nuclei[0].γ))
                        .font(.headline) +
                    Text(" MHz")
                        .font(.body)
                }
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                
            }
            .frame(width: geometry.size.width)
            .background(Color.secondary)
        }
    }
}

struct WatchNucleusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return WatchNucleusDetailView(nucleus: UserData().nuclei[3])
            .environmentObject(UserData())
    }
}
