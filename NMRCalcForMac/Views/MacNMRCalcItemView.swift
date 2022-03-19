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
    @Binding var value: Double?
    var unit: String
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
        
            Text(unit)
                .font(.body)
                .frame(width: defaultUnitTextWidth, alignment: .leading)
        }
        .foregroundColor(Color.secondary)
    }
    
}

struct MacSignalItemView_Previews: PreviewProvider {
    @State static var value: Double? = 1.0
    static var previews: some View {
        MacNMRCalcItemView(title: "Dwell time", titleFont: .body, value: $value, unit: "μs", formatter: NumberFormatter()) {
        }
    }
}
