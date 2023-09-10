//
//  TimeDomainView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct TimeDomainView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State var numberOfTimeDataPoints: Double
    @State var acquisitionDuration: Double
    @State var dwellTime: Double
    
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
                                  value: $numberOfTimeDataPoints,
                                  unit: NMRCalcUnit.none,
                                  formatter: dataPointsFormatter) {
                if calculator.validate(numberOfDataPoints: numberOfTimeDataPoints) {
                    calculator.update(.acquisitionSize, to: numberOfTimeDataPoints)
                } else {
                    showDataPointsAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Acquisition duration",
                                  titleFont: .body,
                                  value: $acquisitionDuration,
                                  unit: NMRCalcUnit.sec,
                                  formatter: durationTimeFormatter) {
                if calculator.isPositive(acquisitionDuration) {
                    calculator.update(.acquisitionTime, to: acquisitionDuration)
                } else {
                    showAlert.toggle()
                }
            }
            
            NMRCalculatorItemView(title: "Dwell time",
                                  titleFont: .body,
                                  value: $dwellTime,
                                  unit: NMRCalcUnit.μs,
                                  formatter: durationTimeFormatter) {
                if calculator.isPositive(dwellTime) {
                    calculator.update(.dwellTimeInμs, to: dwellTime)
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
        numberOfTimeDataPoints = calculator.numberOfTimeDataPoints
        acquisitionDuration = calculator.acquisitionDuration
        dwellTime = calculator.dwellTime
    }
}

