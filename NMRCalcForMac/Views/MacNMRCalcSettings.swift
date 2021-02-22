//
//  MacNMRCalcSettings.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/22/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcSettings: View {
    @AppStorage("MacNucleusView.elementColor")
    private var elementColor: ElementColor = .systemGreen
    
    @AppStorage("MacNucleusView.numberColor")
    private var numberColor: MacNMRCalcSettings.NumberColor = .systemPurple
    
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
    
    var body: some View {
        Form {
            Picker("Element Color:", selection: $elementColor) {
                ForEach(MacNMRCalcSettings.ElementColor.allCases) { color in
                    Text(color.rawValue)
                }
            }
            .pickerStyle(InlinePickerStyle())
            
            Picker("Number Color:", selection: $numberColor) {
                ForEach(MacNMRCalcSettings.NumberColor.allCases) { color in
                    Text(color.rawValue)
                }
            }
            .pickerStyle(InlinePickerStyle())
        }
        .frame(width: 300)
        .navigationTitle("MacNucleusView Settings")
        .padding(80)
    }
}

struct MacNMRCalcSettings_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcSettings()
    }
}
