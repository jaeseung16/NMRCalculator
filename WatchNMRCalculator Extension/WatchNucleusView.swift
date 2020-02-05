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
                    Text("Nuclear Spin")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.secondary)
                    
                    WatchNuclearSpinView(nucleus: self.nucleus)
                        .font(.body)
                        .foregroundColor(Color.primary)
                    
                    self.generateDetailView(for: "\(String(format: "%.2f", abs(self.nucleus.γ)))", title: "MHz/T")
                    
                    self.generateDetailView(for: self.nucleus.naturalAbundance, title: "NA")
                }
                .scaledToFill()
            }
            .frame(width: geometry.size.width)
        }
    }
    
    private func generateDetailView(for item: String, title: String) -> some View {
        VStack(alignment: .trailing) {
            Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(Color.secondary)
            
            Text(item)
            .font(.body)
            .foregroundColor(Color.primary)
        }
    }
}

struct WatchNucleusView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNucleusView(nucleus: UserData().nuclei[16])
    }
}
