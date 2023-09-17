//
//  CalculatorItem.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/10/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation
import SwiftUI

class CalculatorItem: ObservableObject, Identifiable, Hashable, CustomDebugStringConvertible {
    var debugDescription: String {
        return "CalculatorItem[id=\(id)]"
    }
    
    static func == (lhs: CalculatorItem, rhs: CalculatorItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: NMRCalcCommandName
    
    let command: NMRCalcCommandName
    let title: String
    let font: Font
    @Published var value: Double
    let unit: NMRCalcUnit
    let formatter: NumberFormatter
    let callback: (Double) -> Void
    
    init(command: NMRCalcCommandName, title: NMRCalcConstants.Title, font: Font, value: Double, unit: NMRCalcUnit, formatter: NumberFormatter, callback: @escaping (Double) -> Void) {
        self.command = command
        self.title = title.rawValue
        self.font = font
        self.value = value
        self.unit = unit
        self.formatter = formatter
        self.callback = callback
        self.id = command
    }
}
