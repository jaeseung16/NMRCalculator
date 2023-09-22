//
//  MacCalculatorView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/23/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacCalculatorView: View {
    var title: NMRPeriodicTableData.Property
    @Binding var value: Double?
    var unit: NMRPeriodicTableData.Unit
    var onSubmit: () -> Void
    
    @AppStorage("NucleusView.numberColor")
    private var numberColor: NumberColor = .systemPurple
    
    private let defaultLabel = "0.0"
    private let defaultTextFieldWidth: CGFloat = 100
    private let defaultUnitTextWidth: CGFloat = 40
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title.rawValue)
                .font(.callout)
            
            Spacer()
            
            TextField(defaultLabel, value: $value, formatter: numberFormatter)
                .onSubmit { onSubmit() }
                .multilineTextAlignment(.trailing)
                .frame(width: defaultTextFieldWidth)
                .font(Font.body.weight(.semibold))
                .foregroundColor(numberColor.getColor())
            
            Text(unit.rawValue)
                .font(.body)
                .frame(width: defaultUnitTextWidth, alignment: .leading)
        }
        .foregroundColor(Color.primary)
    }
}

struct MacCalculatorView_Previews: PreviewProvider {
    static let title = NMRPeriodicTableData.Property.externalField
    @State static var value: Double? = 0.0
    static let unit = NMRPeriodicTableData.Unit.T
    
    static var previews: some View {
        MacCalculatorView(title: title, value: $value, unit: unit) {
            print("\(title) = \(String(describing: value)) \(unit)")
        }
    }
}
