//
//  Pulse2View.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct Pulse2View: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State var duration2: Double
    @State var flipAngle2: Double
    @State var amplitude2: Double
    @State var relativePower: Double

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
                                  value: $duration2,
                                  unit: NMRCalcUnit.μs,
                                  formatter: durationFormatter) {
                if calculator.isPositive(duration2) {
                    calculator.update(.pulse2Duration, to: duration2)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Flip angle",
                                  titleFont: .body,
                                  value: $flipAngle2,
                                  unit: NMRCalcUnit.degree,
                                  formatter: flipAngleFormatter) {
                if calculator.isPositive(flipAngle2) {
                    calculator.update(.pulse2FlipAngle, to: flipAngle2)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "RF Amplitude",
                                  titleFont: .body,
                                  value: $amplitude2,
                                  unit: NMRCalcUnit.Hz,
                                  formatter: amplitudeFormatter) {
                if calculator.isPositive(amplitude2) {
                    calculator.update(.pulse2Amplitude, to: amplitude2)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "RF power relateve to Pulse 1",
                                  titleFont: .body,
                                  value: $relativePower,
                                  unit: NMRCalcUnit.dB,
                                  formatter: relativePowerFormatter) {
                calculator.relativePower = relativePower
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
        duration2 = calculator.duration2
        flipAngle2 = calculator.flipAngle2
        amplitude2 = calculator.amplitude2
        relativePower = calculator.relativePower
    }
}
