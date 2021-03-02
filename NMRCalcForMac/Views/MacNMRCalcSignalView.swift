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
                MacNMRCalcItemView(title: "Number of data points", value: $signalCalculator.numberOfTimeDataPoint, unit: "") {
                    _ = signalCalculator.$numberOfTimeDataPoint
                        .filter() { $0 != nil }
                        .sink() { _ in
                            signalCalculator.numberOfTimeDataPointUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Acquisition duration", value: $signalCalculator.acquisitionDuration, unit: "sec") {
                    _ = signalCalculator.$acquisitionDuration
                        .filter() { $0 != nil }
                        .sink() { _ in
                            signalCalculator.acquisitionDurationUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Dwell time", value: $signalCalculator.dwellTime, unit: "μs") {
                    _ = signalCalculator.$dwellTime
                        .filter() { $0 != nil }
                        .sink() { _ in
                            signalCalculator.dwellTimeUpdated()
                        }
                }
            }
            
            Section(header: Text("Frequency Domain")) {
                MacNMRCalcItemView(title: "Number of data points", value: $signalCalculator.numberOfFrequencyDataPoint, unit: "") {
                    _ = signalCalculator.$numberOfFrequencyDataPoint
                        .filter() { $0 != nil }
                        .sink() { _ in
                            signalCalculator.numberOfFrequencyDataPointUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Spectral width", value: $signalCalculator.spectralWidth, unit: "kHz") {
                    _ = signalCalculator.$spectralWidth
                        .filter() { $0 != nil }
                        .sink() { _ in
                            signalCalculator.spectralWidthUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Frequency resolution", value: $signalCalculator.frequencyResolution, unit: "Hz") {
                    _ = signalCalculator.$frequencyResolution
                        .filter() { $0 != nil }
                        .sink() { _ in
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
