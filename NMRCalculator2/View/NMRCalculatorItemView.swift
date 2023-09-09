//
//  NMRCalculatorItemView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NMRCalculatorItemView: View {
    private let defaultLabel = "0.0"
    private let defaultTextFieldWidth: CGFloat = 120
    private let defaultUnitTextWidth: CGFloat = 40
    private let numberColor: Color = .purple
    
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
                .foregroundColor(numberColor)
        
            Text(unit.rawValue)
                .font(.body)
                .frame(width: defaultUnitTextWidth, alignment: .leading)
        }
        .foregroundColor(Color.secondary)
    }
    
}
