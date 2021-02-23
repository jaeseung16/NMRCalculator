//
//  NucleusList.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusList: View {
    @EnvironmentObject var userData: NMRPeriodicTableData
    @ObservedObject var calculator = MacNMRCalculator()
    
    @State var externalField = 1.0
    @State private var isEditing = false
    
    let proton = NMRNucleus()
    
    var nucleus: NMRNucleus {
        return calculator.nucleus ?? proton
    }
    
    var elementSymbol: String {
        return nucleus.symbolNucleus
    }
    
    var atomicWeight: UInt {
        return UInt(nucleus.atomicWeight)!
    }
    
    var gyromagneticRatio: Double {
        return Double(nucleus.gyromagneticRatio)!
    }
    
    var body: some View {
        HStack(alignment: .center) {
            MacLamorFrequencyView()
            .environmentObject(calculator)
            .frame(width: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Divider()
            
            List(selection: $calculator.nucleus, content: {
                ForEach(userData.nuclei, id: \.self) { nucleus in
                    HStack {
                        Spacer()
                        MacNucleusView(nucleus: nucleus)
                            .frame(width: 150, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .tag(nucleus)
                        Spacer()
                    }
                }
            })
            .listStyle(PlainListStyle())
            .onChange(of: calculator.nucleus, perform: { value in
                _ = calculator.$nucleus.sink { nucleus in
                    calculator.nucluesUpdated()
                }
            })
        }
        .frame(width: 500, height: 400, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct MacNucleusList_Previews: PreviewProvider {
    static var previews: some View {
        let userData = NMRPeriodicTableData()
        return MacNucleusList().environmentObject(userData)
    }
}
