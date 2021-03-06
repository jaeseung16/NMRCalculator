//
//  AppDelegate.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 3/5/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var helpWindow: NSWindow!
    
    @objc func openHelpWindow() {
        if helpWindow == nil {
            // Create the SwiftUI view that provides the window contents.
            let contentView = MacNMRCalcHelpView()
                
            // Create the preferences window and set content
            helpWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 612, height: 792),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            helpWindow.center()
            helpWindow.setFrameAutosaveName("Guide")
            helpWindow.isReleasedWhenClosed = false
            helpWindow.contentView = NSHostingView(rootView: contentView)
        }
        
        helpWindow.makeKeyAndOrderFront(nil)
    }
    
}
