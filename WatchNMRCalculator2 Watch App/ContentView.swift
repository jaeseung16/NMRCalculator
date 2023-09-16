//
//  ContentView.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/13/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: NMRPeriodicTableData
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List(userData.nuclei) { nucleus in
                    NavigationLink(value: nucleus) {
                        WatchNucleusView(nucleus: nucleus)
                    }
                    .navigationTitle("NMR Calculator 2")
                    .navigationBarTitleDisplayMode(.inline)
                    .frame(width: geometry.size.width * 0.88, height: geometry.size.height * 0.7)
                }
                .navigationDestination(for: NMRNucleus.self) { nucleus in
                    WatchNucleusDetailView(nucleus: nucleus)
                }
            }
        }
    }
}

