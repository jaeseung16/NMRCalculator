//
//  NMRCalcItemView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NMRCalcItemView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @StateObject var calculatorItem: CalculatorItem
    
    private let defaultLabel = "0.0"
    private let defaultTextFieldWidth: CGFloat = 120
    private let defaultUnitTextWidth: CGFloat = 40
    private let numberColor: Color = .purple

    var body: some View {
        HStack(alignment: .center) {
            Text(calculatorItem.title)
                .font(calculatorItem.font)
        
            Spacer()
        
            TextField(defaultLabel, value: $calculatorItem.value, formatter: calculatorItem.formatter)
                .onSubmit { calculatorItem.callback(calculatorItem.value) }
                .multilineTextAlignment(.trailing)
                .font(Font.body.weight(.semibold))
                .frame(width: defaultTextFieldWidth)
                .foregroundColor(numberColor)
        
            Text(calculatorItem.unit.rawValue)
                .font(.body)
                .frame(width: defaultUnitTextWidth, alignment: .leading)
        }
        .foregroundColor(Color.secondary)
    }

}
