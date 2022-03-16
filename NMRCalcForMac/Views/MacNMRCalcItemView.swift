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
    @Binding var value: Double?
    var unit: String
    var onSubmit: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.body)
        
            Spacer()
        
            TextField(defaultLabel, value: $value, formatter: numberFormatter)
                .onSubmit {
                    onSubmit()
                }
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
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter
    }
}

struct MacSignalItemView_Previews: PreviewProvider {
    @State static var value: Double? = 1.0
    static var previews: some View {
        MacNMRCalcItemView(title: "Dwell time", value: $value, unit: "μs") {
        }
    }
}
