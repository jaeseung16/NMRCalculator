//
//  MacSignalItemView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcItemView: View {
    private let defaultLabel = "0.0"
    private let defaultTextFieldWidth: CGFloat = 100
    private let defaultUnitTextWidth: CGFloat = 40
    @State private var isEditing = false
    
    @AppStorage("NucleusView.numberColor")
    private var numberColor: NumberColor = .systemPurple
    
    var title: String
    var titleFont: Font
    @Binding var value: Double
    var unit: NMRCalcUnit
    var formatter: NumberFormatter
    var onSubmit: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(titleFont)
        
            Spacer()
        
            TextField(defaultLabel, value: $value, formatter: formatter)
                .onSubmit { onSubmit() }
                .multilineTextAlignment(.trailing)
                .font(Font.body.weight(.semibold))
                .frame(width: defaultTextFieldWidth)
                .foregroundColor(numberColor.getColor())
        
            Text(unit.rawValue)
                .font(.body)
                .frame(width: defaultUnitTextWidth, alignment: .leading)
        }
        .foregroundColor(Color.secondary)
    }
    
}

