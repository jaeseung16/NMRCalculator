//
//  ElementColor.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/22/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

enum ElementColor: String, CaseIterable, Identifiable {
    case systemBlue
    case systemGreen
    case systemYellow
    
    var id: ElementColor {
        return self
    }
    
    public func getColor() -> Color {
        var nsColor: NSColor
        switch (self) {
        case .systemBlue:
            nsColor = NSColor.systemBlue
        case .systemGreen:
            nsColor = NSColor.systemGreen
        case .systemYellow:
            nsColor = NSColor.systemYellow
        }
        return Color(nsColor)
    }
}
