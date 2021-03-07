//
//  MacLamorFrequencyView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/31/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacLamorFrequencyView: View {
    @EnvironmentObject var calculator: NucleusCalculatorViewModel
    
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
            AtomicElementView(elementSymbol: elementSymbol, massNumber: atomicWeight, weight: .semibold)
                .foregroundColor(elementColor.getColor())
            
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
            .padding()
            
            VStack {
                MacCalculatorView(title: .externalField,
                                  value: $calculator.externalField,
                                  unit: .T) {
                    _ = calculator.$externalField
                        .filter() { (newValue) -> Bool in
                            newValue != nil
                        }
                        .sink() {
                            let externalField = $0 ?? 1.0
                            if externalField < 0.0 {
                                calculator.externalField = 0.0
                            } else if externalField > 1000.0 {
                                calculator.externalField = 1000.0
                            }
                            calculator.externalFieldUpdated()
                        }
                }
               
                MacCalculatorView(title: .larmorFrequency,
                                  value: $calculator.larmorFrequency,
                                  unit: .MHz) {
                    _ = calculator.$larmorFrequency
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.larmorFrequencyUpdated()
                        }
                }
                
                MacCalculatorView(title: .protonFrequency,
                                  value: $calculator.protonFrequency,
                                  unit: .MHz) {
                    _ = calculator.$protonFrequency
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.protonFrequencyUpdated()
                        }
                }
                
                MacCalculatorView(title: .electronFrequency,
                                  value: $calculator.electronFrequency,
                                  unit: .GHz) {
                    _ = calculator.$electronFrequency
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.electronFrequencyUpdated()
                        }
                }
                
            }
            .padding()
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
    @StateObject static var calculator = NucleusCalculatorViewModel()
    
    static var previews: some View {
        MacLamorFrequencyView()
            .environmentObject(calculator)
    }
}
