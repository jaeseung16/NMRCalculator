//
//  MacNMRCalcSignalView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcSignalView: View {
    @ObservedObject var signalCalculator = MacNMRSignalCalculator()

    var body: some View {
        VStack {
            Section(header: Text("Time Domain")) {
                MacSignalItemView(title: "Number of data points", value: $signalCalculator.numberOfTimeDataPoint, unit: "") {
                    _ = signalCalculator.$numberOfTimeDataPoint.sink() {_ in
                        signalCalculator.numberOfTimeDataPointUpdated()
                    }
                }
                
                MacSignalItemView(title: "Acquisition duration", value: $signalCalculator.acquisitionDuration, unit: "sec") {
                    _ = signalCalculator.$acquisitionDuration.sink() {_ in
                        signalCalculator.acquisitionDurationUpdated()
                    }
                }
                
                MacSignalItemView(title: "Dwell time", value: $signalCalculator.dwellTime, unit: "μs") {
                    _ = signalCalculator.$dwellTime.sink() {_ in
                        signalCalculator.dwellTimeUpdated()
                    }
                }
            }
            
            Section(header: Text("Frequency Domain")) {
                MacSignalItemView(title: "Number of data points", value: $signalCalculator.numberOfFrequencyDataPoint, unit: "") {
                    _ = signalCalculator.$numberOfFrequencyDataPoint.sink() {_ in
                        signalCalculator.numberOfFrequencyDataPointUpdated()
                    }
                }
                
                MacSignalItemView(title: "Spectral width", value: $signalCalculator.spectralWidth, unit: "kHz") {
                    _ = signalCalculator.$spectralWidth.sink() {_ in
                        signalCalculator.spectralWidthUpdated()
                    }
                }
                
                MacSignalItemView(title: "Frequency resolution", value: $signalCalculator.frequencyResolution, unit: "Hz") {
                    _ = signalCalculator.$frequencyResolution.sink() {_ in
                        signalCalculator.frequencyResolutionUpdated()
                    }
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
