//
//  MacNMRCalcSignalView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcSignalView: View {
    @ObservedObject var calculator = SignalCalculatorViewModel()

    var body: some View {
        VStack {
            Section(header: Text("Time Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points", value: $calculator.numberOfTimeDataPoint, unit: "") {
                    _ = calculator.$numberOfTimeDataPoint
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.numberOfTimeDataPointUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Acquisition duration", value: $calculator.acquisitionDuration, unit: "sec") {
                    _ = calculator.$acquisitionDuration
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.acquisitionDurationUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Dwell time", value: $calculator.dwellTime, unit: "μs") {
                    _ = calculator.$dwellTime
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.dwellTimeUpdated()
                        }
                }
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                MacNMRCalcItemView(title: "Number of data points", value: $calculator.numberOfFrequencyDataPoint, unit: "") {
                    _ = calculator.$numberOfFrequencyDataPoint
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.numberOfFrequencyDataPointUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Spectral width", value: $calculator.spectralWidth, unit: "kHz") {
                    _ = calculator.$spectralWidth
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.spectralWidthUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Frequency resolution", value: $calculator.frequencyResolution, unit: "Hz") {
                    _ = calculator.$frequencyResolution
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.frequencyResolutionUpdated()
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
