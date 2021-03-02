//
//  ContentView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusContentView: View {
    var body: some View {
        TabView {
            MacNucleusList()
                .tabItem {
                    Text("Nucleus")
                }
            
            MacNMRCalcSignalView()
                .tabItem {
                    Text("Signal")
                }
            
            MacNMRCalcPulseView()
                .tabItem {
                    Text("RF Pulse")
                }
            
            MacNMRCalcErnstAngleView()
                .tabItem {
                    Text("Ernst Angle")
                }
        }
        .frame(width: 500, height: 400, alignment: .center)
    }
}

struct MacNucleusContentView_Previews: PreviewProvider {
    static var previews: some View {
        MacNucleusContentView()
    }
}
