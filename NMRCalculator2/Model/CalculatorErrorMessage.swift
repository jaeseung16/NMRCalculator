//
//  CalculatorErrorMessage.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/11/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation

enum CalculatorErrorMessage: String {
    case shouldBePositiveValue = "Try a positive value."
    case shouldBeBetweenZeroAndNinety = "Try a value between 0 and 90 exclusive"
    case shouldBeNaturalNumber = "Try a natural number."
    case shouldBeBetweenNegativeOneThousandAndOneThousand = "Try a value between -1000 to 1000"
}
