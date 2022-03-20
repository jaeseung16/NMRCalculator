//
//  MacNMRCalcSignalView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcSignalView: View {
    @EnvironmentObject private var viewModel: MacNMRCalculatorViewModel

    @State var numberOfTimeDataPoint: Double
    @State var acquisitionDuration: Double
    @State var dwellTime: Double
    @State var numberOfFrequencyDataPoint: Double
    @State var spectralWidth: Double
    @State var frequencyResolution: Double
    
    @State private var showAlert = false
    
    private let alertMessage = "Try a positive value."
    
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
                                   value: $numberOfTimeDataPoint,
                                   unit: "",
                                   formatter: dataPointsFormatter) {
                    let previousValue = viewModel.numberOfTimeDataPoints
                    viewModel.numberOfTimeDataPoints = numberOfTimeDataPoint
                    if viewModel.validateNumberOfTimeDataPoint() {
                        viewModel.numberOfTimeDataPointUpdated()
                        acquisitionDuration = viewModel.acquisitionDuration
                        dwellTime = viewModel.dwellTime
                    } else {
                        numberOfTimeDataPoint = previousValue
                        viewModel.numberOfTimeDataPoints = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Acquisition duration",
                                   titleFont: .body,
                                   value: $acquisitionDuration,
                                   unit: "sec",
                                   formatter: durationTimeFormatter) {
                    let previousValue = viewModel.acquisitionDuration
                    viewModel.acquisitionDuration = acquisitionDuration
                    if viewModel.validateAcquisitionDuration() {
                        viewModel.acquisitionDurationUpdated()
                        numberOfTimeDataPoint = viewModel.numberOfTimeDataPoints
                        dwellTime = viewModel.dwellTime
                    } else {
                        acquisitionDuration = previousValue
                        viewModel.acquisitionDuration = previousValue
                        showAlert.toggle()
                    }
                    
                }
                
                MacNMRCalcItemView(title: "Dwell time",
                                   titleFont: .body,
                                   value: $dwellTime,
                                   unit: "μs",
                                   formatter: durationTimeFormatter) {
                    let previousValue = viewModel.dwellTime
                    viewModel.dwellTime = dwellTime
                    if viewModel.validateDwellTime() {
                        viewModel.dwellTimeUpdated()
                        numberOfTimeDataPoint = viewModel.numberOfTimeDataPoints
                        acquisitionDuration = viewModel.acquisitionDuration
                    } else {
                        dwellTime = previousValue
                        viewModel.dwellTime = previousValue
                        showAlert.toggle()
                    }
                }
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points",
                                   titleFont: .body,
                                   value: $numberOfFrequencyDataPoint,
                                   unit: "",
                                   formatter: dataPointsFormatter) {
                    let previousValue = viewModel.numberOfFrequencyDataPoints
                    viewModel.numberOfFrequencyDataPoints = numberOfFrequencyDataPoint
                    if viewModel.validateNumberOfFrequencyDataPoint() {
                        viewModel.numberOfFrequencyDataPointUpdated()
                        spectralWidth = viewModel.spectralWidth
                        frequencyResolution = viewModel.frequencyResolution
                    } else {
                        numberOfFrequencyDataPoint = previousValue
                        viewModel.numberOfFrequencyDataPoints = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Spectral width",
                                   titleFont: .body,
                                   value: $spectralWidth,
                                   unit: "kHz",
                                   formatter: durationTimeFormatter) {
                    let previousValue = viewModel.spectralWidth
                    viewModel.spectralWidth = spectralWidth
                    if viewModel.validateSpectralWidth() {
                        viewModel.spectralWidthUpdated()
                        numberOfFrequencyDataPoint = viewModel.numberOfFrequencyDataPoints
                        frequencyResolution = viewModel.frequencyResolution
                    } else {
                        spectralWidth = previousValue
                        viewModel.spectralWidth = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Frequency resolution",
                                   titleFont: .body,
                                   value: $frequencyResolution,
                                   unit: "Hz",
                                   formatter: durationTimeFormatter) {
                    let previousValue = viewModel.frequencyResolution
                    viewModel.frequencyResolution = frequencyResolution
                    if viewModel.validateFrequencyResolution() {
                        viewModel.frequencyResolutionUpdated()
                        numberOfFrequencyDataPoint = viewModel.numberOfFrequencyDataPoints
                        spectralWidth = viewModel.spectralWidth
                    } else {
                        frequencyResolution = previousValue
                        viewModel.frequencyResolution = previousValue
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
    
    private func validateTimeDomainParameters() {
        if numberOfTimeDataPoint < 0 {
            numberOfTimeDataPoint = 0
        }
    }
    
}

