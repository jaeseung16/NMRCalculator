//
//  MacLamorFrequencyView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/31/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacLamorFrequencyView: View {
    @EnvironmentObject var viewModel: MacNMRCalculatorViewModel
    @AppStorage("NucleusView.elementColor") private var elementColor: ElementColor = .systemGreen
    
    private var proton: NMRNucleus {
        return viewModel.proton
    }
    
    private var nucleus: NMRNucleus {
        return  viewModel.nucleus ?? proton
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
        VStack {
            AtomicElementView(elementSymbol: elementSymbol, massNumber: atomicWeight, weight: .semibold)
                .foregroundColor(elementColor.getColor())
            
            displayInfo()
                .padding()
            
            VStack {
                MacCalculatorView(title: .externalField,
                                  value: $viewModel.externalField,
                                  unit: .T) {
                    viewModel.validateExternalField()
                    viewModel.externalFieldUpdated()
                }
               
                MacCalculatorView(title: .larmorFrequency,
                                  value: $viewModel.larmorFrequency,
                                  unit: .MHz) {
                    viewModel.larmorFrequencyUpdated()
                }
                
                MacCalculatorView(title: .protonFrequency,
                                  value: $viewModel.protonFrequency,
                                  unit: .MHz) {
                    viewModel.protonFrequencyUpdated()
                }
                
                MacCalculatorView(title: .electronFrequency,
                                  value: $viewModel.electronFrequency,
                                  unit: .GHz) {
                    viewModel.electronFrequencyUpdated()
                }
            }
            .padding()
        }
    }
    
    private func displayInfo() -> some View {
        VStack() {
            getInfoView(title: .nuclearSpin,
                        value: Fraction(from: nuclearSpin,
                                        isPositive: gyromagneticRatio > 0).inlineDescription
            )
            
            getInfoView(title: .gyromagneticRatio,
                        value: "\(String(format: "%.6f", abs(gyromagneticRatio)))"
            )
            
            getInfoView(title: .naturalAbundance,
                        value: "\(naturalAbundance)"
            )
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

struct MacLamorFrequencyView_Previews: PreviewProvider {
    @StateObject static var viewModel = MacNMRCalculatorViewModel()
    
    static var previews: some View {
        MacLamorFrequencyView()
            .environmentObject(viewModel)
    }
}
