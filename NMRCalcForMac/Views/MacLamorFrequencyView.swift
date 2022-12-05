//
//  MacLamorFrequencyView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/31/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacLamorFrequencyView: View {
    @EnvironmentObject private var viewModel: MacNMRCalculatorViewModel
    @AppStorage("NucleusView.elementColor") private var elementColor: ElementColor = .systemGreen
    
    @Binding var nucleus: NMRNucleus
    @State var larmorFrequency: Double
    @State var protonFrequency: Double
    @State var electronFrequency: Double
    @State var externalField: Double
    
    private var proton: NMRNucleus {
        return viewModel.proton
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
    private let alertMessage = "Try a value between -1000 to 1000"
    
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
                                   value: $externalField,
                                   unit: NMRCalcUnit.T,
                                   formatter: externalFieldFormatter) {
                    if viewModel.validate(externalField: externalField) {
                        viewModel.update(externalField: externalField)
                    } else {
                        showAlert.toggle()
                    }
                }
               
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.larmorFrequency.rawValue,
                                   titleFont: .callout,
                                   value: $larmorFrequency,
                                   unit: NMRCalcUnit.MHz,
                                   formatter: frequencyFormatter) {
                    viewModel.update(larmorFrequency: larmorFrequency)
                }
                
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.protonFrequency.rawValue,
                                   titleFont: .callout,
                                   value: $protonFrequency,
                                   unit: NMRCalcUnit.MHz,
                                   formatter: frequencyFormatter) {
                    viewModel.update(protonFrequency: protonFrequency)
                }
                
                MacNMRCalcItemView(title: NMRPeriodicTableData.Property.electronFrequency.rawValue,
                                   titleFont: .callout,
                                   value: $electronFrequency,
                                   unit: NMRCalcUnit.GHz,
                                   formatter: frequencyFormatter) {
                    viewModel.update(electronFrequency: electronFrequency)
                }
            }
            .padding()
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK") {
                    externalField = viewModel.externalField
                    showAlert.toggle()
                }
            }
            .onReceive(viewModel.$nucleusUpdated) { _ in
                larmorFrequency = viewModel.larmorFrequency
                protonFrequency = viewModel.protonFrequency
                electronFrequency = viewModel.electronFrequency
                externalField = viewModel.externalField
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
