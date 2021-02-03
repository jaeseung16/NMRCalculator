//
//  NucleusList.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusList<DetailView: View>: View {
    @EnvironmentObject var userData: UserData
    
    @State var selected: NMRNucleus?
    @State var externalField = 1.0
    @State private var isEditing = false
    
    let detailViewProducer: (NMRNucleus) -> DetailView
    let proton = NMRNucleus()
    
    var nucleus: NMRNucleus {
        return self.selected ?? proton
    }
    
    var elementSymbol: String {
        return self.nucleus.symbolNucleus
    }
    
    var atomicWeight: UInt {
        return UInt(self.nucleus.atomicWeight)!
    }
    
    var gyromagneticRatio: Double {
        return Double(self.nucleus.gyromagneticRatio)!
    }
    
    @ObservedObject var calculator = MacNMRCalculator()
    
    var body: some View {
        VStack(alignment: .center) {
            MacLamorFrequencyView(
                externalField: externalField,
                protonFrequency: MacLamorFrequencyView.gammaProton * externalField,
                electronFrequency: MacLamorFrequencyView.gammaElectron * externalField
            )
            .environmentObject(calculator)
            /*
            Slider(
                value: $externalField,
                in: 0...100,
                onEditingChanged: { editing in
                       isEditing = editing
                }
            )
            .padding(1.0)
            
            HStack {
                WatchAtomicElementView(
                    elementSymbol: elementSymbol,
                    massNumber: atomicWeight)
                    .scaledToFill()
                    .foregroundColor(Color.accentColor)
                
                LarmorFrequencyView(externalField: self.externalField, gyromatneticRatio: gyromagneticRatio)
                
                ProtonFrequencyView(protonFrquency: self.externalField * UserData.γProton)
            }
            */
            Divider()
            
            List(selection: $calculator.nucleus, content: {
                ForEach(self.userData.nuclei, id: \.self) { nucleus in
                    HStack {
                        Spacer()
                        MacNucleusView(nucleus: nucleus)
                            .frame(width: 200, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
            
            /*
            List {
                ForEach(self.userData.nuclei, id: \.self) { nucleus in
                    HStack {
                        Spacer()
                        
                        MacNucleusView(nucleus: nucleus)
                            .frame(width: 200, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .tag(nucleus)
    
                        Spacer()
                    }
                    .onTapGesture {
                        self.selected = nucleus
                    }
                }
            }
            .listStyle(PlainListStyle())
            //.colorMultiply(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            */
        }
        .frame(maxWidth: 300, maxHeight: 600, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
    }
}

struct MacNucleusList_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        return MacNucleusList {MacNucleusView(nucleus: $0)}
            .environmentObject(userData)
    }
}
