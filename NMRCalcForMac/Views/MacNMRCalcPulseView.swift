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

    var body: some View {
        VStack {
            Section(header: Text("First Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration", value: $viewModel.duration1, unit: "μs") {
                    viewModel.duration1Updated()
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $viewModel.flipAngle1, unit: "°") {
                    viewModel.flipAngle1Updated()
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $viewModel.amplitude1, unit: "Hz") {
                    viewModel.amplitude1Updated()
                }
                
                if let nucleus = viewModel.nucleus {
                    MacNMRCalcItemView(title: "RF Amplitude for \(nucleus.nameNucleus)", value: $viewModel.amplitude1InT, unit: "μT") {
                        viewModel.amplitude1Updated()
                    }
                }
            }
            
            Section(header: Text("Second Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration", value: $viewModel.duration2, unit: "μs") {
                    viewModel.duration2Updated()
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $viewModel.flipAngle2, unit: "°") {
                    viewModel.flipAngle2Updated()
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $viewModel.amplitude2, unit: "Hz") {
                    viewModel.amplitude2Updated()
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st", value: $viewModel.relativePower, unit: "dB") {
                    viewModel.relativePowerUpdated()
                }
            }
        }
        .padding()
    }
    
}

struct MacNMRCalcPulseView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcPulseView()
    }
}
