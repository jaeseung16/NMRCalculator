//
//  ContentView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusContentView: View {
    @EnvironmentObject private var viewModel: MacNMRCalculatorViewModel
    
    var body: some View {
        TabView {
            MacNucleusList(selectedNucleus: viewModel.nucleus)
                .tabItem {
                    Text("Nucleus")
                }
            
            MacNMRCalcSignalView(numberOfTimeDataPoints: viewModel.numberOfTimeDataPoints,
                                 acquisitionDuration: viewModel.acquisitionDuration,
                                 dwellTime: viewModel.dwellTime,
                                 numberOfFrequencyDataPoints: viewModel.numberOfFrequencyDataPoints,
                                 spectralWidth: viewModel.spectralWidth,
                                 frequencyResolution: viewModel.frequencyResolution)
            .tabItem { Text("Signal") }
            
            MacNMRCalcPulseView(duration1: viewModel.duration1,
                                flipAngle1: viewModel.flipAngle1,
                                amplitude1: viewModel.amplitude1,
                                amplitude1InT: viewModel.amplitude1InT,
                                duration2: viewModel.duration2,
                                flipAngle2: viewModel.flipAngle2,
                                amplitude2: viewModel.amplitude2,
                                relativePower: viewModel.relativePower)
            .tabItem { Text("RF Pulse") }
            
            MacNMRCalcErnstAngleView(repetitionTime: viewModel.repetitionTime,
                                     relaxationTime: viewModel.relaxationTime,
                                     ernstAngle: viewModel.ernstAngle)
            .tabItem { Text("Ernst Angle") }
        }
        .frame(width: 500, height: 400, alignment: .center)
    }
}

struct MacNucleusContentView_Previews: PreviewProvider {
    static var previews: some View {
        MacNucleusContentView()
    }
}
