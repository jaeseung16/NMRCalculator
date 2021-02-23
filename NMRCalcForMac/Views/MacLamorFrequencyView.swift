//
//  MacLamorFrequencyView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/31/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacLamorFrequencyView: View {
    @EnvironmentObject var calculator: MacNMRCalculator
    
    private let proton = NMRNucleus()
    
    private var nucleus: NMRNucleus {
        return  calculator.nucleus ?? proton
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
   
    @AppStorage("MacNucleusView.elementColor")
    private var elementColor: ElementColor = .systemGreen
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                Text("\(atomicWeight)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    
                Text(elementSymbol)
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(elementColor.getColor())
            
            VStack() {
                getInfoView(title: "Nuclear Spin", value: Fraction(from: nuclearSpin, isPositive: gyromagneticRatio > 0).inlineDescription)
                
                getInfoView(title: "Gyromagnetic Ratio (MHz/T)", value: "\(String(format: "%.6f", abs(gyromagneticRatio)))")
                
                getInfoView(title: "Natural Abundance (%)", value: "\(naturalAbundance)")
            }
            .padding()
            
            VStack {
                MacCalculatorView(title: "External Field", value: $calculator.externalField, unit: "T") {
                    _ = calculator.$externalField.sink() {
                        let externalField = $0 ?? 1.0
                        if externalField < 0.0 {
                            calculator.externalField = 0.0
                        } else if externalField > 1000.0 {
                            calculator.externalField = 1000.0
                        }
                        calculator.externalFieldUpdated()
                    }
                }
               
                MacCalculatorView(title: "Larmor Frequency", value: $calculator.larmorFrequency, unit: "MHz") {
                    _ = calculator.$larmorFrequency.sink() { _ in
                        calculator.larmorFrequencyUpdated()
                    }
                }
                
                MacCalculatorView(title: "Proton Frequency", value: $calculator.protonFrequency, unit: "MHz") {
                    _ = calculator.$protonFrequency.sink() { _ in
                        calculator.protonFrequencyUpdated()
                    }
                }
                
                MacCalculatorView(title: "Electron Frequency", value: $calculator.electronFrequency, unit: "GHz") {
                    _ = calculator.$electronFrequency.sink() { _ in
                        calculator.electronFrequencyUpdated()
                    }
                }
                
            }
            .padding()
        }
    }
    
    private func getInfoView(title: String, value: String) -> some View {
        HStack(alignment: .center) {
            Text(title)
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
    @StateObject static var calculator = MacNMRCalculator()
    
    static var previews: some View {
        MacLamorFrequencyView()
            .environmentObject(calculator)
    }
}
