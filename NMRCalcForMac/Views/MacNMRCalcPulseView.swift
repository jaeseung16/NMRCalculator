//
//  MacNMRCalcPulseView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcPulseView: View {
    @EnvironmentObject var viewModel: MacNMRCalculatorViewModel

    @State private var showAlert = false
    
    private var alertMessage = "Try a positive value."
    
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
                                   value: $viewModel.duration1,
                                   unit: "μs",
                                   formatter: durationFormatter) {
                    if viewModel.validateDuration1() {
                        viewModel.duration1Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle",
                                   titleFont: .body,
                                   value: $viewModel.flipAngle1,
                                   unit: "°",
                                   formatter: flipAngleFormatter) {
                    if viewModel.validateFlipAngle1() {
                        viewModel.flipAngle1Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude",
                                   titleFont: .body,
                                   value: $viewModel.amplitude1,
                                   unit: "Hz",
                                   formatter: amplitudeFormatter) {
                    if viewModel.validateAmplitude1() {
                        viewModel.amplitude1Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                if let nucleus = viewModel.nucleus {
                    MacNMRCalcItemView(title: "RF Amplitude for \(nucleus.nameNucleus)",
                                       titleFont: .body,
                                       value: $viewModel.amplitude1InT,
                                       unit: "μT",
                                       formatter: amplitudeFormatter) {
                        if viewModel.validateAmplitude1InT() {
                            viewModel.amplitude1Updated()
                        } else {
                            showAlert.toggle()
                        }
                    }
                }
            }
            
            Section(header: Text("Second Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration",
                                   titleFont: .body,
                                   value: $viewModel.duration2,
                                   unit: "μs",
                                   formatter: durationFormatter) {
                    if viewModel.validateDuration2() {
                        viewModel.duration2Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle",
                                   titleFont: .body,
                                   value: $viewModel.flipAngle2, unit: "°",
                                   formatter: flipAngleFormatter) {
                    if viewModel.validateFlipAngle2() {
                        viewModel.flipAngle2Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude",
                                   titleFont: .body,
                                   value: $viewModel.amplitude2,
                                   unit: "Hz",
                                   formatter: amplitudeFormatter) {
                    if viewModel.validateAmplitude2() {
                        viewModel.amplitude2Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st",
                                   titleFont: .body,
                                   value: $viewModel.relativePower,
                                   unit: "dB",
                                   formatter: relativePowerFormatter) {
                    viewModel.relativePowerUpdated()
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

struct MacNMRCalcPulseView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcPulseView()
    }
}
