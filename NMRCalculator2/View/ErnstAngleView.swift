//
//  ErnstAngleView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct ErnstAngleView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State var repetitionTime: Double
    @State var relaxationTime: Double
    @State var ernstAngle: Double
    
    @State private var showAlert = false
    @State private var showAlertErnstAngle = false
    
    private let alertMessage = "Try a positive value."
    private let ernstAngleAlertMessage = "Try a value between 0 and 90 exclusive"
    
    private var flipAngleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var relaxationTimeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        VStack {
            NMRCalculatorItemView(title: "Repetition Time",
                                  titleFont: .body,
                                  value: $repetitionTime,
                                  unit: NMRCalcUnit.sec,
                                  formatter: relaxationTimeFormatter) {
                if calculator.isNonNegative(repetitionTime) {
                    calculator.update(.repetitionTime, to: repetitionTime)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Relaxation Time",
                                  titleFont: .body,
                                  value: $relaxationTime,
                                  unit: NMRCalcUnit.sec,
                                  formatter: relaxationTimeFormatter) {
                if calculator.isPositive(relaxationTime) {
                    calculator.update(.relaxationTime, to: relaxationTime)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Ernst Angle",
                                  titleFont: .body,
                                  value: $ernstAngle,
                                  unit: NMRCalcUnit.degree,
                                  formatter: flipAngleFormatter) {
                if calculator.validate(ernstAngle: ernstAngle) {
                    calculator.update(.ernstAngle, to: ernstAngle)
                } else {
                    showAlertErnstAngle.toggle()
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
        .alert(ernstAngleAlertMessage, isPresented: $showAlertErnstAngle) {
            Button("OK") {
                reset()
                showAlertErnstAngle.toggle()
            }
        }
        .onReceive(calculator.$updated) { _ in
            reset()
        }
    }
    
    private func reset() {
        repetitionTime = calculator.repetitionTime
        relaxationTime = calculator.relaxationTime
        ernstAngle = calculator.ernstAngle
    }
}
