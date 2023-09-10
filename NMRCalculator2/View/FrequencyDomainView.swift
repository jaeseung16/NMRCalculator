//
//  SpectralWidthView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct FrequencyDomainView: View {
    @EnvironmentObject private var calculator: NMRCalculator2

    @State var numberOfFrequencyDataPoints: Double
    @State var spectralWidth: Double
    @State var frequencyResolution: Double
    
    @State private var showAlert = false
    @State private var showDataPointsAlert = false
    
    private let alertMessage = "Try a positive value."
    private let dataPointsAlertMessage = "Try a natural whole number."
    
    private var dataPointsFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    private var durationTimeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        VStack {
            NMRCalculatorItemView(title: "Number of data points",
                                  titleFont: .body,
                                  value: $numberOfFrequencyDataPoints,
                                  unit: NMRCalcUnit.none,
                                  formatter: dataPointsFormatter) {
                if calculator.validate(numberOfDataPoints: numberOfFrequencyDataPoints) {
                    calculator.update(.spectrumSize, to: numberOfFrequencyDataPoints)
                } else {
                    showDataPointsAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Spectral width",
                                  titleFont: .body,
                                  value: $spectralWidth,
                                  unit: NMRCalcUnit.kHz,
                                  formatter: durationTimeFormatter) {
                if calculator.isPositive(spectralWidth) {
                    calculator.update(.spectralWidthInkHz, to: spectralWidth)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Frequency resolution",
                                  titleFont: .body,
                                  value: $frequencyResolution,
                                  unit: NMRCalcUnit.Hz,
                                  formatter: durationTimeFormatter) {
                if calculator.isPositive(frequencyResolution) {
                    calculator.update(.frequencyResolution, to: frequencyResolution)
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
        .alert(dataPointsAlertMessage, isPresented: $showDataPointsAlert) {
            Button("OK") {
                reset()
                showDataPointsAlert.toggle()
            }
        }
        .onReceive(calculator.$updated) { _ in
            reset()
        }
       
    }
    
    private func reset() -> Void {
        numberOfFrequencyDataPoints = calculator.numberOfFrequencyDataPoints
        spectralWidth = calculator.spectralWidth
        frequencyResolution = calculator.frequencyResolution
    }
}

