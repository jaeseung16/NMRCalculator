//
//  Pulse1View.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct Pulse1View: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State var duration1: Double
    @State var flipAngle1: Double
    @State var amplitude1: Double
    @State var amplitude1InT: Double

    @State private var showAlert = false
    
    private let alertMessage = "Try a positive value."
    
    private var amplitudeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var durationFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var flipAngleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var relativePowerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        VStack {
            NMRCalculatorItemView(title: "Pulse duration",
                                  titleFont: .body,
                                  value: $duration1,
                                  unit: NMRCalcUnit.μs,
                                  formatter: durationFormatter) {
                if calculator.isPositive(duration1) {
                    calculator.update(.pulse1Duration, to: duration1)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Flip angle",
                                  titleFont: .body,
                                  value: $flipAngle1,
                                  unit: NMRCalcUnit.degree,
                                  formatter: flipAngleFormatter) {
                if calculator.isPositive(flipAngle1) {
                    calculator.update(.pulse1FlipAngle, to: flipAngle1)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "RF Amplitude",
                                  titleFont: .body,
                                  value: $amplitude1,
                                  unit: NMRCalcUnit.Hz,
                                  formatter: amplitudeFormatter) {
                if calculator.isPositive(amplitude1) {
                    calculator.update(.pulse1Amplitude, to: amplitude1)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "RF Amplitude for \(calculator.nucleusName)",
                                  titleFont: .body,
                                  value: $amplitude1InT,
                                  unit: NMRCalcUnit.μT,
                                  formatter: amplitudeFormatter) {
                if calculator.isPositive(abs(amplitude1InT)) {
                    calculator.update(pulse1AmplitudeInT: calculator.γNucleus >= 0 ? abs(amplitude1InT) : -abs(amplitude1InT))
                } else {
                    showAlert.toggle()
                }
            }
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                reset()
                showAlert.toggle()
            }
        }
        .onReceive(calculator.$updated) { _ in
            reset()
        }
    }
    
    private func reset() {
        duration1 = calculator.duration1
        flipAngle1 = calculator.flipAngle1
        amplitude1 = calculator.amplitude1
        amplitude1InT = calculator.amplitude1InT
        amplitude1InT = calculator.amplitude1InT
    }
}

