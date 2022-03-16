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
    
    var body: some View {
        VStack {
            Section(header: Text("First Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration", value: $viewModel.duration1, unit: "μs") {
                    if viewModel.validateDuration1() {
                        viewModel.duration1Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $viewModel.flipAngle1, unit: "°") {
                    if viewModel.validateFlipAngle1() {
                        viewModel.flipAngle1Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $viewModel.amplitude1, unit: "Hz") {
                    if viewModel.validateAmplitude1() {
                        viewModel.amplitude1Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                if let nucleus = viewModel.nucleus {
                    MacNMRCalcItemView(title: "RF Amplitude for \(nucleus.nameNucleus)", value: $viewModel.amplitude1InT, unit: "μT") {
                        if viewModel.validateAmplitude1InT() {
                            viewModel.amplitude1Updated()
                        } else {
                            showAlert.toggle()
                        }
                    }
                }
            }
            
            Section(header: Text("Second Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration", value: $viewModel.duration2, unit: "μs") {
                    if viewModel.validateDuration2() {
                        viewModel.duration2Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $viewModel.flipAngle2, unit: "°") {
                    if viewModel.validateFlipAngle2() {
                        viewModel.flipAngle2Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $viewModel.amplitude2, unit: "Hz") {
                    if viewModel.validateAmplitude2() {
                        viewModel.amplitude2Updated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st", value: $viewModel.relativePower, unit: "dB") {
                    viewModel.relativePowerUpdated()
                }
            }
        }
        .padding()
        .alert("Try another value", isPresented: $showAlert) {
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
