//
//  MacNMRCalcPulseView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcPulseView: View {
    @EnvironmentObject private var viewModel: MacNMRCalculatorViewModel
    
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
            Section(header: Text("First Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration",
                                   titleFont: .body,
                                   value: $duration1,
                                   unit: "μs",
                                   formatter: durationFormatter) {
                    let previousValue = viewModel.duration1
                    viewModel.duration1 = duration1
                    if viewModel.validateDuration1() {
                        viewModel.duration1Updated()
                        flipAngle1 = viewModel.flipAngle1
                        amplitude1 = viewModel.amplitude1
                        amplitude1InT = viewModel.amplitude1InT
                        relativePower = viewModel.relativePower
                    } else {
                        duration1 = previousValue
                        viewModel.duration1 = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle",
                                   titleFont: .body,
                                   value: $flipAngle1,
                                   unit: "°",
                                   formatter: flipAngleFormatter) {
                    let previousValue = viewModel.flipAngle1
                    viewModel.flipAngle1 = flipAngle1
                    if viewModel.validateFlipAngle1() {
                        viewModel.flipAngle1Updated()
                        duration1 = viewModel.duration1
                        amplitude1 = viewModel.amplitude1
                        amplitude1InT = viewModel.amplitude1InT
                        relativePower = viewModel.relativePower
                    } else {
                        flipAngle1 = previousValue
                        viewModel.flipAngle1 = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude",
                                   titleFont: .body,
                                   value: $amplitude1,
                                   unit: "Hz",
                                   formatter: amplitudeFormatter) {
                    let previousValue = viewModel.amplitude1
                    viewModel.amplitude1 = amplitude1
                    if viewModel.validateAmplitude1() {
                        viewModel.amplitude1Updated()
                        duration1 = viewModel.duration1
                        flipAngle1 = viewModel.flipAngle1
                        amplitude1InT = viewModel.amplitude1InT
                        relativePower = viewModel.relativePower
                    } else {
                        amplitude1 = previousValue
                        viewModel.amplitude1 = previousValue
                        showAlert.toggle()
                    }
                }
                
                if let nucleus = viewModel.nucleus {
                    MacNMRCalcItemView(title: "RF Amplitude for \(nucleus.nameNucleus)",
                                       titleFont: .body,
                                       value: $amplitude1InT,
                                       unit: "μT",
                                       formatter: amplitudeFormatter) {
                        let previousValue = viewModel.amplitude1InT
                        viewModel.amplitude1InT = amplitude1InT
                        if viewModel.validateAmplitude1InT() {
                            viewModel.amplitude1InTUpdated()
                            duration1 = viewModel.duration1
                            flipAngle1 = viewModel.flipAngle1
                            amplitude1 = viewModel.amplitude1
                            relativePower = viewModel.relativePower
                        } else {
                            amplitude1InT = previousValue
                            viewModel.amplitude1InT = previousValue
                            showAlert.toggle()
                        }
                    }
                }
            }
            
            Section(header: Text("Second Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration",
                                   titleFont: .body,
                                   value: $duration2,
                                   unit: "μs",
                                   formatter: durationFormatter) {
                    let previousValue = viewModel.duration2
                    viewModel.duration2 = duration2
                    if viewModel.validateDuration2() {
                        viewModel.duration2Updated()
                        flipAngle2 = viewModel.flipAngle2
                        amplitude2 = viewModel.amplitude2
                        relativePower = viewModel.relativePower
                    } else {
                        duration2 = previousValue
                        viewModel.duration2 = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle",
                                   titleFont: .body,
                                   value: $flipAngle2, unit: "°",
                                   formatter: flipAngleFormatter) {
                    let previousValue = viewModel.flipAngle2
                    viewModel.flipAngle2 = flipAngle2
                    if viewModel.validateFlipAngle2() {
                        viewModel.flipAngle2Updated()
                        duration2 = viewModel.duration2
                        amplitude2 = viewModel.amplitude2
                        relativePower = viewModel.relativePower
                    } else {
                        flipAngle2 = previousValue
                        viewModel.flipAngle2 = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude",
                                   titleFont: .body,
                                   value: $amplitude2,
                                   unit: "Hz",
                                   formatter: amplitudeFormatter) {
                    let previousValue = viewModel.amplitude2
                    viewModel.amplitude2 = amplitude2
                    if viewModel.validateAmplitude2() {
                        viewModel.amplitude2Updated()
                        duration2 = viewModel.duration2
                        flipAngle2 = viewModel.flipAngle2
                        relativePower = viewModel.relativePower
                    } else {
                        amplitude2 = previousValue
                        viewModel.amplitude2 = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st",
                                   titleFont: .body,
                                   value: $relativePower,
                                   unit: "dB",
                                   formatter: relativePowerFormatter) {
                    viewModel.relativePower = relativePower
                    viewModel.relativePowerUpdated()
                    duration2 = viewModel.duration2
                    flipAngle2 = viewModel.flipAngle2
                    amplitude2 = viewModel.amplitude2
                }
            }
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                showAlert.toggle()
            }
        }
    }
    
}

