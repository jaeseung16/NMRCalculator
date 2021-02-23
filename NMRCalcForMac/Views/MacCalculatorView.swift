//
//  MacCalculatorView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/23/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacCalculatorView: View {
    private let defaultLabel = "0.0"
    private let defaultTextFieldWidth: CGFloat = 100
    private let defaultUnitTextWidth: CGFloat = 40
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    @State private var isEditing = false
    
    @AppStorage("MacNucleusView.numberColor")
    private var numberColor: NumberColor = .systemPurple
    
    var title: String
    @Binding var value: Double?
    var unit: String
    
    var onCommit: () -> Void
    
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.callout)
            
            Spacer()
            
            TextField(defaultLabel, value: $value,
                      formatter: numberFormatter) { isEditing in
                self.isEditing = isEditing
            } onCommit: {
                onCommit()
            }
            .multilineTextAlignment(.trailing)
            .frame(width: defaultTextFieldWidth)
            .font(Font.body.weight(.semibold))
            .foregroundColor(numberColor.getColor())
            
            Text(unit)
                .font(.body)
                .frame(width: defaultUnitTextWidth, alignment: .leading)
        }
        .foregroundColor(Color.primary)
    }
}

struct MacCalculatorView_Previews: PreviewProvider {
    static let title = "External Field"
    @State static var value: Double? = 0.0
    static let unit = "T"
    
    static var previews: some View {
        MacCalculatorView(title: title, value: $value, unit: unit) {
            print("\(title) = \(String(describing: value)) \(unit)")
        }
    }
}
