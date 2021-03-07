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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MacNucleusContentView()
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button(action: {
                        NSApp.sendAction(#selector(AppDelegate.openHelpWindow), to: nil, from:nil)
                }) {
                    Text("NMRCalcForMac Guide")
                }
            }
        }
        
        #if os(macOS)
        Settings {
            MacNMRCalcSettings()
        }
        #endif
    }
}
