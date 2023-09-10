//
//  PulseView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct PulseView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @State var duration1: Double
    @State var flipAngle1: Double
    @State var amplitude1: Double
    @State var amplitude1InT: Double
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
            Section(header: Text("Pulse 1")) {
                Pulse1View(duration1: calculator.duration1,
                          flipAngle1: calculator.flipAngle1,
                          amplitude1: calculator.amplitude1,
                          amplitude1InT: calculator.amplitude1InT)
                .environmentObject(calculator)
            }
            
            Section(header: Text("Pulse 2")) {
                Pulse2View(duration2: calculator.duration2,
                          flipAngle2: calculator.flipAngle2,
                          amplitude2: calculator.amplitude2,
                          relativePower: calculator.relativePower)
                .environmentObject(calculator)
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
        
        duration2 = calculator.duration2
        flipAngle2 = calculator.flipAngle2
        amplitude2 = calculator.amplitude2
        relativePower = calculator.relativePower
        
        amplitude1InT = calculator.amplitude1InT
    }
}
