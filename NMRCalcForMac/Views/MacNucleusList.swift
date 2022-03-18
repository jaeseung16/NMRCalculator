//
//  NucleusList.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusList: View {
    @EnvironmentObject private var viewModel: MacNMRCalculatorViewModel
    
    private let periodicTable = NMRPeriodicTableData()
    private let proton = NMRNucleus()
    
    @State private var selectedSpin: Float = 0.0
    private var possibleSpins: [Float] = [-4.5, -4.0, -3.5, -2.5, -1.5, -0.5, 0.0, 0.5, 1.0, 1.5, 2.5, 3.0, 3.5, 4.5, 5.0, 6.0, 7.0]
    
    private var filteredNuclei: [NMRNucleus] {
        if selectedSpin != 0 {
            return periodicTable.nuclei.filter {
                guard let gyromagneticRatio = Double($0.gyromagneticRatio) else {
                    return false
                }
                return $0.nuclearSpin == label(for: abs(selectedSpin)) && gyromagneticRatio * Double(selectedSpin) >= 0.0
            }
        } else {
            return periodicTable.nuclei
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            MacLamorFrequencyView()
                .frame(width: 300, alignment: .center)
            
            Divider()
            
            VStack {
                FilterView()
                    .padding(.horizontal, 8.0)
                
                Divider()
                
                ListView()
            }
        }
    }
    
    private func label(for spin: Float) -> String {
        guard spin != 0.0 else {
            return "ALL"
        }
        
        let temp = Int(abs(spin * 2.0))
        if temp % 2 == 0 {
            return Fraction(positive: spin > 0, numerator: UInt(abs(spin)), denominator: UInt(1)).inlineDescription
        } else {
            return Fraction(positive: spin > 0, numerator: UInt(temp), denominator: UInt(2)).inlineDescription
        }
    }
    
    private func FilterView() -> some View {
        Picker(selection: $selectedSpin) {
            ForEach(possibleSpins, id: \.self) {
                Text(label(for: $0))
            }
        } label: {
            Text("nuclear spin")
                .foregroundColor(.secondary)
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    private func ListView() -> some View {
        List(selection: $viewModel.nucleus) {
            ForEach(filteredNuclei, id: \.self) { nucleus in
                HStack {
                    Spacer()
                    MacNucleusView(nucleus: nucleus)
                        .frame(width: 150, height: 100, alignment: .center)
                        .tag(nucleus)
                    Spacer()
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct MacNucleusList_Previews: PreviewProvider {
    static var previews: some View {
        return MacNucleusList()
    }
}
