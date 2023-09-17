//
//  LarmorFrequencyView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct LarmorFrequencyView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State var larmorFrequency: Double
    @State var protonFrequency: Double
    @State var electronFrequency: Double
    @State var externalField: Double
    
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
            NMRCalculatorItemView(title: NMRCalcConstants.Title.externalField.rawValue,
                               titleFont: .callout,
                               value: $externalField,
                               unit: NMRCalcUnit.T,
                               formatter: externalFieldFormatter) {
                if calculator.validate(externalField: externalField) {
                    calculator.update(.magneticField, to: externalField)
                } else {
                    showAlert.toggle()
                }
            }
           
            NMRCalculatorItemView(title: NMRCalcConstants.Title.larmorFrequency.rawValue,
                               titleFont: .callout,
                               value: $larmorFrequency,
                               unit: NMRCalcUnit.MHz,
                               formatter: frequencyFormatter) {
                calculator.update(.larmorFrequency, to: larmorFrequency)
            }
            
            NMRCalculatorItemView(title: NMRCalcConstants.Title.protonFrequency.rawValue,
                               titleFont: .callout,
                               value: $protonFrequency,
                               unit: NMRCalcUnit.MHz,
                               formatter: frequencyFormatter) {
                calculator.update(.protonFrequency, to: protonFrequency)
            }
            
            NMRCalculatorItemView(title: NMRCalcConstants.Title.electronFrequency.rawValue,
                               titleFont: .callout,
                               value: $electronFrequency,
                               unit: NMRCalcUnit.GHz,
                               formatter: frequencyFormatter) {
                calculator.update(.electronFrequency, to: electronFrequency)
            }
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                externalField = calculator.externalField
                showAlert.toggle()
            }
        }
        .onReceive(calculator.$updated) { _ in
            larmorFrequency = calculator.larmorFrequency
            protonFrequency = calculator.protonFrequency
            electronFrequency = calculator.electronFrequency
            externalField = calculator.externalField
        }
    }
}

