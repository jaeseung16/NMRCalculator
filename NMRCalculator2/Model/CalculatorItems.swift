//
//  CalculatorItems.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation

class CalculatorItems: ObservableObject {
    var items: [CalculatorItem]
    
    init(items: [CalculatorItem]) {
        self.items = items
    }
}
