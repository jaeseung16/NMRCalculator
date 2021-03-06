//
//  NucleusList.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusList: View {
    let userData = NMRPeriodicTableData()
    @ObservedObject var calculator = NucleusCalculatorViewModel()

    let proton = NMRNucleus()
    
    var nucleus: NMRNucleus {
        return calculator.nucleus ?? proton
    }
    
    var body: some View {
        HStack(alignment: .center) {
            MacLamorFrequencyView()
                .environmentObject(calculator)
                .frame(width: 300, alignment: .center)
            
            Divider()
            
            List(selection: $calculator.nucleus) {
                ForEach(userData.nuclei, id: \.self) { nucleus in
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
            .onChange(of: calculator.nucleus) { value in
                _ = calculator.$nucleus.sink { nucleus in
                    calculator.nucluesUpdated()
                }
            }
        }
    }
}

struct MacNucleusList_Previews: PreviewProvider {
    static var previews: some View {
        return MacNucleusList()
    }
}
