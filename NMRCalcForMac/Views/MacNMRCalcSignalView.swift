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

    var body: some View {
        VStack {
            Section(header: Text("Time Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points", value: $viewModel.numberOfTimeDataPoint, unit: "") {
                    viewModel.validateNumberOfTimeDataPoint()
                    viewModel.numberOfTimeDataPointUpdated()
                }
                
                MacNMRCalcItemView(title: "Acquisition duration", value: $viewModel.acquisitionDuration, unit: "sec") {
                    viewModel.validateAcquisitionDuration()
                    viewModel.acquisitionDurationUpdated()
                }
                
                MacNMRCalcItemView(title: "Dwell time", value: $viewModel.dwellTime, unit: "μs") {
                    viewModel.validateDwellTime()
                    viewModel.dwellTimeUpdated()
                }
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points", value: $viewModel.numberOfFrequencyDataPoint, unit: "") {
                    viewModel.validateNumberOfFrequencyDataPoint()
                    viewModel.numberOfFrequencyDataPointUpdated()
                }
                
                MacNMRCalcItemView(title: "Spectral width", value: $viewModel.spectralWidth, unit: "kHz") {
                    viewModel.validateSpectralWidth()
                    viewModel.spectralWidthUpdated()
                }
                
                MacNMRCalcItemView(title: "Frequency resolution", value: $viewModel.frequencyResolution, unit: "Hz") {
                    viewModel.validateFrequencyResolution()
                    viewModel.frequencyResolutionUpdated()
                }
            }
        }
        .padding()
    }
    
}

struct MacNMRCalcSignalView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcSignalView()
    }
}
