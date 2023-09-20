//
//  NMRCalculatorSectionView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NMRCalculatorSectionView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    @StateObject var calculatorItems: CalculatorItems
    
    var body: some View {
        ForEach(calculatorItems.items) { calculatorItem in
            NMRCalculatorItemView(calculatorItem: calculatorItem)
                .environmentObject(calculator)
        }
        .onChange(of: calculator.updated) { _ in
            calculator.refresh(calculatorItems)
        }
    }
}
