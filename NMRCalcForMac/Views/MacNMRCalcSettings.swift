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
    private var numberColor: NumberColor = .systemPurple
    
    var body: some View {
        Form {
            Picker("Element Color:", selection: $elementColor) {
                ForEach(ElementColor.allCases) { color in
                    Text(color.rawValue)
                }
            }
            .pickerStyle(InlinePickerStyle())
            
            Picker("Number Color:", selection: $numberColor) {
                ForEach(NumberColor.allCases) { color in
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
