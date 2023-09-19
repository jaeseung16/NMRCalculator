//
//  NucleusDetailView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NucleusDetailView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State private var showAlert = false
    
    var nucleus: NMRNucleus
    
    private var proton: NMRNucleus {
        return NMRPeriodicTable.shared.proton
    }
    
    private var elementSymbol: String {
        return nucleus.symbolNucleus
    }
    
    private var atomicWeight: UInt {
        return UInt(nucleus.atomicWeight)!
    }
    
    private var nuclearSpin: String {
        return Fraction(from: nucleus.nuclearSpin, isPositive: nucleus.γ > 0).inlineDescription
    }
    
    private var naturalAbundance: String {
        return nucleus.naturalAbundance
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                AtomicElementView(elementSymbol: nucleus.symbolNucleus,
                                  massNumber: UInt(nucleus.atomicWeight)!)
                displayInfo()
                    .frame(minWidth: 0.5 * geometry.size.width, maxWidth: 0.8 * geometry.size.width, alignment: .center)
                
                Divider()
                    .frame(height: 1)
                    .overlay(Color.secondary)
                
                ScrollView {
                    VStack {
                        ForEach(CalculationType.allCases) { calculationType in
                            Section {
                                NMRCalculatorSectionView(calculatorItems: calculator.items(for: calculationType))
                                    .environmentObject(calculator)
                            } header: {
                                Text(calculationType.rawValue)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
            .alert(calculator.alertMessage, isPresented: $showAlert) {
                Button("OK") {
                    showAlert.toggle()
                    if !showAlert {
                        calculator.showAlert = showAlert
                    }
                }
            }
            .onChange(of: calculator.showAlert) { newValue in
                if newValue {
                    showAlert = newValue
                }
            }
        }
    }
    
    private func displayInfo() -> some View {
        VStack {
            getInfoView(title: .nuclearSpin, value: nuclearSpin)
            getInfoView(title: .gyromagneticRatio, value: String(format: "%.6f", abs(nucleus.γ)))
            getInfoView(title: .naturalAbundance, value: naturalAbundance)
        }
    }
    
    private func getInfoView(title: NMRCalcConstants.Title, value: String) -> some View {
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
