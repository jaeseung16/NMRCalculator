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
   
    @State private var showAlert = false
    private var alertMessage = "Try a value between -1000 to 1000."
    
    private var externalFieldFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var frequencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 6
        return formatter
    }
    
    var body: some View {
        VStack {
            AtomicElementView(elementSymbol: elementSymbol, massNumber: atomicWeight, weight: .semibold)
                .foregroundColor(elementColor.getColor())
            
            displayInfo()
                .padding()
            
            VStack {
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.externalField.rawValue,
                                   titleFont: .callout,
                                   value: $viewModel.externalField,
                                   unit: NMRPeriodicTableData.Unit.T.rawValue,
                                   formatter: externalFieldFormatter) {
                    if viewModel.validateExternalField() {
                        viewModel.externalFieldUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
               
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.larmorFrequency.rawValue,
                                   titleFont: .callout,
                                   value: $viewModel.larmorFrequency,
                                   unit: NMRPeriodicTableData.Unit.MHz.rawValue,
                                   formatter: frequencyFormatter) {
                    viewModel.larmorFrequencyUpdated()
                }
                
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.protonFrequency.rawValue,
                                   titleFont: .callout,
                                   value: $viewModel.protonFrequency,
                                   unit: NMRPeriodicTableData.Unit.MHz.rawValue,
                                   formatter: frequencyFormatter) {
                    viewModel.protonFrequencyUpdated()
                }
                
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.electronFrequency.rawValue,
                                   titleFont: .callout,
                                   value: $viewModel.electronFrequency,
                                   unit: NMRPeriodicTableData.Unit.GHz.rawValue,
                                   formatter: frequencyFormatter) {
                    viewModel.electronFrequencyUpdated()
                }
            }
            .padding()
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK") {
                    showAlert.toggle()
                }
            }
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
