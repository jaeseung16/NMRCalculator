//
//  MacNMRCalcSignalView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcSignalView: View {
    @EnvironmentObject var viewModel: MacNMRCalculatorViewModel

    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Section(header: Text("Time Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points", value: $viewModel.numberOfTimeDataPoint, unit: "") {
                    if viewModel.validateNumberOfTimeDataPoint() {
                        viewModel.numberOfTimeDataPointUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Acquisition duration", value: $viewModel.acquisitionDuration, unit: "sec") {
                    if viewModel.validateAcquisitionDuration() {
                        viewModel.acquisitionDurationUpdated()
                    } else {
                        showAlert.toggle()
                    }
                    
                }
                
                MacNMRCalcItemView(title: "Dwell time", value: $viewModel.dwellTime, unit: "μs") {
                    if viewModel.validateDwellTime() {
                        viewModel.dwellTimeUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points", value: $viewModel.numberOfFrequencyDataPoint, unit: "") {
                    if viewModel.validateNumberOfFrequencyDataPoint() {
                        viewModel.numberOfFrequencyDataPointUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Spectral width", value: $viewModel.spectralWidth, unit: "kHz") {
                    if viewModel.validateSpectralWidth() {
                        viewModel.spectralWidthUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Frequency resolution", value: $viewModel.frequencyResolution, unit: "Hz") {
                    if viewModel.validateFrequencyResolution() {
                        viewModel.frequencyResolutionUpdated()
                    } else {
                        showAlert.toggle()
                    }
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

struct MacNMRCalcSignalView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcSignalView()
    }
}
