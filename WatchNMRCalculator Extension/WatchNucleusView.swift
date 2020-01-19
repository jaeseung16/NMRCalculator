//
//  WatchNucleusView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusView: View {
    @EnvironmentObject var userData: UserData
    var nucleus: NMRNucleus
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            WatchAtomicElementView(
                elementSymbol: self.nucleus.symbolNucleus,
                massNumber: UInt(self.nucleus.atomicWeight)!)
                .scaledToFit()
            
            Spacer()
            
            VStack(alignment: .trailing) {
                WatchNuclearSpinView(nucleus: self.nucleus)
                    .font(.body)
                    .scaledToFit()
                
                Text("\(String(format: "%.2f", abs(self.nucleus.γ)))")
                    .font(.body)
                    .scaledToFit()
            }
        }
        .padding()
        .background(Color.yellow)
        .foregroundColor(Color.blue)
    }
}

struct WatchNucleusView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNucleusView(nucleus: NMRNucleus())
            .environmentObject(UserData())
    }
}
