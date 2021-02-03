//
//  ContentView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MacNucleusList {NucleusDetailView(nucleus: $0)}
            .environmentObject(UserData())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MacNucleusList {NucleusDetailView(nucleus: $0)}
            .environmentObject(UserData())
    }
}
