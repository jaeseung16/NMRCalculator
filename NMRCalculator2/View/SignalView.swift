//
//  SignalView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct SignalView: View {
    @EnvironmentObject private var calculator: NMRCalculator2

    var body: some View {
        VStack {
            Section(header: Text("Time Domain").font(.title2)) {
                TimeDomainView(numberOfTimeDataPoints: calculator.numberOfTimeDataPoints,
                               acquisitionDuration: calculator.acquisitionDuration,
                               dwellTime: calculator.dwellTime)
                .environmentObject(calculator)
            }
            
            Section(header: Text("Frequency Domain").font(.title2)) {
                FrequencyDomainView(numberOfFrequencyDataPoints: calculator.numberOfFrequencyDataPoints,
                                    spectralWidth: calculator.spectralWidth,
                                    frequencyResolution: calculator.frequencyResolution)
                .environmentObject(calculator)
            }
        }
        .padding()
    }
}
