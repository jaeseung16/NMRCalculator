//
//  NumberColor.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/22/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

enum NumberColor: String, CaseIterable, Identifiable {
    case systemOrange
    case systemPurple
    case systemTeal
    
    var id: NumberColor {
        return self
    }
    
    public func getColor() -> Color {
        var nsColor: NSColor
        switch (self) {
        case .systemOrange:
            nsColor = NSColor.systemOrange
        case .systemPurple:
            nsColor = NSColor.systemPurple
        case .systemTeal:
            nsColor = NSColor.systemTeal
        }
        return Color(nsColor)
    }
}
