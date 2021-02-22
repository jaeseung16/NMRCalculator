//
//  NMRCalcForMacApp.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

@main
struct NMRCalcForMacApp: App {
    var body: some Scene {
        WindowGroup {
            MacNucleusContentView()
        }
        
        #if os(macOS)
        Settings {
            MacNMRCalcSettings()
        }
        #endif
    }
}
