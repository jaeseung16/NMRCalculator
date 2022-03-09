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
    
    @State var selected: NMRNucleus?
    
    var body: some View {
        HStack(alignment: .center) {
            MacLamorFrequencyView()
                .frame(width: 300, alignment: .center)
            
            Divider()
            
            List(selection: $selected) {
                ForEach(periodicTable.nuclei, id: \.self) { nucleus in
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
            .onChange(of: selected) { _ in
                viewModel.nucleus = selected
                viewModel.nucluesUpdated()
            }
        }
    }
}

struct MacNucleusList_Previews: PreviewProvider {
    static var previews: some View {
        return MacNucleusList()
    }
}
