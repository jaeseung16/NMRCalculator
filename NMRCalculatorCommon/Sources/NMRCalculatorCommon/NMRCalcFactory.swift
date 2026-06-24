//
//  NMRCalcFactory.swift
//  NMRCalculatorCommon
//
//  Created by Jae Seung Lee on 5/23/26.
//

public enum NMRCalcFactory: NMRCalcLoading {
    case shared
    
    public func create(_ type: CalculatorType) -> any NMRCalcDelegate {
        switch type {
        case .larmor:
            return LarmorFrequencyCalculator()
        case .time:
            return TimeDomainCalculator()
        case .frequency:
            return FrequencyDomainCalculator()
        case .pulse:
            return PulseParameterCalculator()
        case .decibel:
            return DecibelCalculator()
        case .ernst:
            return ErnstAngleCalculator()
        }
    }
}
