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

    @State var numberOfTimeDataPoints: Double
    @State var acquisitionDuration: Double
    @State var dwellTime: Double
    @State var numberOfFrequencyDataPoints: Double
    @State var spectralWidth: Double
    @State var frequencyResolution: Double
    
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
            Section(header: Text("Time Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points",
                                   titleFont: .body,
                                   value: $numberOfTimeDataPoints,
                                   unit: NMRCalcUnit.none,
                                   formatter: dataPointsFormatter) {
                    if viewModel.validate(numberOfDataPoints: numberOfTimeDataPoints) {
                        viewModel.update(.acquisitionSize, to: numberOfTimeDataPoints)
                    } else {
                        showDataPointsAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Acquisition duration",
                                   titleFont: .body,
                                   value: $acquisitionDuration,
                                   unit: NMRCalcUnit.sec,
                                   formatter: durationTimeFormatter) {
                    if viewModel.isPositive(acquisitionDuration) {
                        viewModel.update(.acquisitionTime, to: acquisitionDuration)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Dwell time",
                                   titleFont: .body,
                                   value: $dwellTime,
                                   unit: NMRCalcUnit.μs,
                                   formatter: durationTimeFormatter) {
                    if viewModel.isPositive(dwellTime) {
                        viewModel.update(.dwellTimeInμs, to: dwellTime)
                    } else {
                        showAlert.toggle()
                    }
                }
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points",
                                   titleFont: .body,
                                   value: $numberOfFrequencyDataPoints,
                                   unit: NMRCalcUnit.none,
                                   formatter: dataPointsFormatter) {
                    if viewModel.validate(numberOfDataPoints: numberOfFrequencyDataPoints) {
                        viewModel.update(.spectrumSize, to: numberOfFrequencyDataPoints)
                    } else {
                        showDataPointsAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Spectral width",
                                   titleFont: .body,
                                   value: $spectralWidth,
                                   unit: NMRCalcUnit.kHz,
                                   formatter: durationTimeFormatter) {
                    if viewModel.isPositive(spectralWidth) {
                        viewModel.update(.spectralWidthInkHz, to: spectralWidth)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Frequency resolution",
                                   titleFont: .body,
                                   value: $frequencyResolution,
                                   unit: NMRCalcUnit.Hz,
                                   formatter: durationTimeFormatter) {
                    if viewModel.isPositive(frequencyResolution) {
                        viewModel.update(.frequencyResolution, to: frequencyResolution)
                    } else {
                        showAlert.toggle()
                    }
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
        .onReceive(viewModel.$timeDomainUpdated) { _ in
            reset()
        }
        .onReceive(viewModel.$frequencyDomainUpdated) { _ in
            reset()
        }
       
    }
    
    private func reset() -> Void {
        numberOfTimeDataPoints = viewModel.numberOfTimeDataPoints
        acquisitionDuration = viewModel.acquisitionDuration
        dwellTime = viewModel.dwellTime
        numberOfFrequencyDataPoints = viewModel.numberOfFrequencyDataPoints
        spectralWidth = viewModel.spectralWidth
        frequencyResolution = viewModel.frequencyResolution
    }
    
}

