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
                                   unit: NMRCalcUnit.μs,
                                   formatter: durationFormatter) {
                    if viewModel.isPositive(duration1) {
                        viewModel.update(.pulse1Duration, to: duration1)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle",
                                   titleFont: .body,
                                   value: $flipAngle1,
                                   unit: NMRCalcUnit.degree,
                                   formatter: flipAngleFormatter) {
                    if viewModel.isPositive(flipAngle1) {
                        viewModel.update(.pulse1FlipAngle, to: flipAngle1)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude",
                                   titleFont: .body,
                                   value: $amplitude1,
                                   unit: NMRCalcUnit.Hz,
                                   formatter: amplitudeFormatter) {
                    if viewModel.isPositive(amplitude1) {
                        viewModel.update(.pulse1Amplitude, to: amplitude1)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude for \(viewModel.nucleus.nameNucleus)",
                                   titleFont: .body,
                                   value: $amplitude1InT,
                                   unit: NMRCalcUnit.μT,
                                   formatter: amplitudeFormatter) {
                    if viewModel.isPositive(abs(amplitude1InT)) {
                        viewModel.update(pulse1AmplitudeInT: viewModel.γNucleus >= 0 ? abs(amplitude1InT) : -abs(amplitude1InT))
                    } else {
                        showAlert.toggle()
                    }
                }
            }
            
            Section(header: Text("Second Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration",
                                   titleFont: .body,
                                   value: $duration2,
                                   unit: NMRCalcUnit.μs,
                                   formatter: durationFormatter) {
                    if viewModel.isPositive(duration2) {
                        viewModel.update(.pulse2Duration, to: duration2)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle",
                                   titleFont: .body,
                                   value: $flipAngle2,
                                   unit: NMRCalcUnit.degree,
                                   formatter: flipAngleFormatter) {
                    if viewModel.isPositive(flipAngle2) {
                        viewModel.update(.pulse2FlipAngle, to: flipAngle2)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude",
                                   titleFont: .body,
                                   value: $amplitude2,
                                   unit: NMRCalcUnit.Hz,
                                   formatter: amplitudeFormatter) {
                    if viewModel.isPositive(amplitude2) {
                        viewModel.update(.pulse2Amplitude, to: amplitude2)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st",
                                   titleFont: .body,
                                   value: $relativePower,
                                   unit: NMRCalcUnit.dB,
                                   formatter: relativePowerFormatter) {
                    viewModel.relativePower = relativePower
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
        .onReceive(viewModel.$pulse1Updated) { _ in
            reset()
        }
        .onReceive(viewModel.$pulse2Updated) { _ in
            reset()
        }
        .onReceive(viewModel.$nucleusUpdated) { _ in
            amplitude1InT = viewModel.amplitude1InT
        }
       
    }
    
    private func reset() {
        duration1 = viewModel.duration1
        flipAngle1 = viewModel.flipAngle1
        amplitude1 = viewModel.amplitude1
        amplitude1InT = viewModel.amplitude1InT
        duration2 = viewModel.duration2
        flipAngle2 = viewModel.flipAngle2
        amplitude2 = viewModel.amplitude2
        relativePower = viewModel.relativePower
    }
    
}

