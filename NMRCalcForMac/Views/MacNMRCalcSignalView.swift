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
    
    private var alertMessage = "Try a positive value."
    
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
            Section(header: Text("Time Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points",
                                   titleFont: .body,
                                   value: $viewModel.numberOfTimeDataPoint,
                                   unit: "",
                                   formatter: dataPointsFormatter) {
                    if viewModel.validateNumberOfTimeDataPoint() {
                        viewModel.numberOfTimeDataPointUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Acquisition duration",
                                   titleFont: .body,
                                   value: $viewModel.acquisitionDuration,
                                   unit: "sec",
                                   formatter: durationTimeFormatter) {
                    if viewModel.validateAcquisitionDuration() {
                        viewModel.acquisitionDurationUpdated()
                    } else {
                        showAlert.toggle()
                    }
                    
                }
                
                MacNMRCalcItemView(title: "Dwell time",
                                   titleFont: .body,
                                   value: $viewModel.dwellTime,
                                   unit: "μs",
                                   formatter: durationTimeFormatter) {
                    if viewModel.validateDwellTime() {
                        viewModel.dwellTimeUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points",
                                   titleFont: .body,
                                   value: $viewModel.numberOfFrequencyDataPoint,
                                   unit: "",
                                   formatter: dataPointsFormatter) {
                    if viewModel.validateNumberOfFrequencyDataPoint() {
                        viewModel.numberOfFrequencyDataPointUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Spectral width",
                                   titleFont: .body,
                                   value: $viewModel.spectralWidth,
                                   unit: "kHz",
                                   formatter: durationTimeFormatter) {
                    if viewModel.validateSpectralWidth() {
                        viewModel.spectralWidthUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Frequency resolution",
                                   titleFont: .body,
                                   value: $viewModel.frequencyResolution,
                                   unit: "Hz",
                                   formatter: durationTimeFormatter) {
                    if viewModel.validateFrequencyResolution() {
                        viewModel.frequencyResolutionUpdated()
                    } else {
                        showAlert.toggle()
                    }
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

struct MacNMRCalcSignalView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcSignalView()
    }
}
