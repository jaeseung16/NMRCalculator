//
//  ContentView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NucleusList {WatchNucleusDetailView(nucleus: $0)}
            .environmentObject(UserData())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NucleusList {WatchNucleusDetailView(nucleus: $0)}
            .environmentObject(UserData())
    }
}
