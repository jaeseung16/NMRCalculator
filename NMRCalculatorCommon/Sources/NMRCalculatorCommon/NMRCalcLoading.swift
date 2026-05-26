//
//  NMRCalculatorFactory.swift
//  NMRCalculatorCommon
//
//  Created by Jae Seung Lee on 5/23/26.
//

public protocol NMRCalcLoading {
    func create(_ type: CalculatorType) -> NMRCalcDelegate
}
