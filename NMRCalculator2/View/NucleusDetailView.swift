//
//  NucleusDetailView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NucleusDetailView: View {
    var nucleus: NMRNucleus
    
    private var proton: NMRNucleus {
        return NMRPeriodicTable.shared.proton
    }
    
    private var elementSymbol: String {
        return nucleus.symbolNucleus
    }
    
    private var atomicWeight: UInt {
        return UInt(nucleus.atomicWeight)!
    }
    
    private var gyromagneticRatio: Double {
        return Double(nucleus.gyromagneticRatio)!
    }
    
    private var nuclearSpin: String {
        return nucleus.nuclearSpin
    }
    
    private var naturalAbundance: String {
        return nucleus.naturalAbundance
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                AtomicElementView(elementSymbol: nucleus.symbolNucleus,
                                  massNumber: UInt(nucleus.atomicWeight)!)
                displayInfo()
                    .frame(minWidth: 0.5 * geometry.size.width, maxWidth: 0.8 * geometry.size.width, alignment: .center)
                
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
    
    private func displayInfo() -> some View {
        VStack {
            getInfoView(title: .nuclearSpin,
                        value: Fraction(from: nuclearSpin, isPositive: gyromagneticRatio > 0).inlineDescription)
            
            getInfoView(title: .gyromagneticRatio,
                        value: "\(String(format: "%.6f", abs(gyromagneticRatio)))")
            
            getInfoView(title: .naturalAbundance,
                        value: "\(naturalAbundance)")
        }
    }
    
    private func getInfoView(title: NMRPeriodicTableData.Property, value: String) -> some View {
        HStack(alignment: .center) {
            Text(title.rawValue)
                .font(.callout)
                .foregroundColor(Color.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(Color.primary)
                .fontWeight(.semibold)
        }
    }
}
