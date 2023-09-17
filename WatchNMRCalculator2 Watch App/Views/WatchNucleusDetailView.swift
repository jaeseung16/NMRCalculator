//
//  WatchNucleusDetailView.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/13/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusDetailView: View {
    @EnvironmentObject var calculator: WatchNMRCalculator2
    
    var nucleus: NMRNucleus
    
    private var externalField: Double {
        return calculator.focus == .ExternalField ? calculator.scrollAmount : calculator.scrollAmount / WatchNMRCalculator2.γProton
    }
    private var protonFrequency: Double {
        return calculator.focus == .ProtonFrequency ? calculator.scrollAmount : calculator.scrollAmount * WatchNMRCalculator2.γProton
    }
    
    private let minValue = 0.0
    private var maxValue: Double {
        return calculator.focus == .ExternalField ? 100 : 2000
    }
    
    private var larmorFrequencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .trailing, spacing: 0) {
                HStack(alignment: .center) {
                    AtomicElementView(elementSymbol: nucleus.symbolNucleus, massNumber: UInt(nucleus.atomicWeight)!)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        NuclearSpinView(nucleus: nucleus)
                            .font(.body)
                                              
                        Text("\(nucleus.naturalAbundance)")
                            .font(.body)
                    }
                    .padding(.trailing, 8)
                }
                .foregroundColor(.green)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                
                VStack(alignment: .trailing, spacing: 0) {
                    HStack(alignment: .top) {
                        Text("\(externalField * nucleus.γ, specifier: "%.4f")")
                            .font(.headline)
                        Text(" \(NMRCalcUnit.MHz.rawValue)")
                            .font(.body)
                    }
                    
                    HStack(alignment: .top, spacing: 0) {
                        Text("@ ")
                        Text("\(Double(externalField), specifier: "%.3f")")
                            .font(.headline)
                        Text(" \(NMRCalcUnit.T.rawValue)")
                            .font(.body)
                    }
                }
                .foregroundColor(calculator.focus == .ProtonFrequency ? .secondary : .primary)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                .onTapGesture {
                    change(focus: .ExternalField)
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Text("\(WatchNMRCalculatorConstant.proton.rawValue)")
                        .font(.caption)

                    HStack(alignment: .center, spacing: 0) {
                        Text("\(protonFrequency, specifier: "%6.4f")")
                            .font(.headline)
                        Text(" \(NMRCalcUnit.MHz.rawValue)")
                            .font(.body)
                    }
                }
                .foregroundColor(calculator.focus == .ProtonFrequency ? .primary : .secondary)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                .onTapGesture {
                    change(focus: .ProtonFrequency)
                }
            }
            .focusable()
            .digitalCrownRotation($calculator.scrollAmount, from: minValue, through: maxValue, by: 0.01, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
    }
    
    private func change(focus: Focus) -> Void {
        calculator.focus = focus
        switch focus {
        case .ExternalField:
            calculator.scrollAmount /= WatchNMRCalculator2.γProton
        case .ProtonFrequency:
            calculator.scrollAmount *= WatchNMRCalculator2.γProton
        }
    }

}
