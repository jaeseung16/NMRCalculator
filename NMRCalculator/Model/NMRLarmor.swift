//
//  NMRLarmor.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/23/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRLarmor {
    // MARK: Properties
    // Constants
    static let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    static let gammaElectron = 176.0859644 / 2 / Double.pi // in GHz/T
    
    // Variables
    var nucleus: NMRNucleus
    
    var frequencyLarmor: Double // in MHz
    var fieldExternal: Double = 1.0 // in T
    var frequencyProton: Double // in MHz
    var frequencyElectron: Double // in GHz
    
    enum Parameter: String {
        case field
        case larmor
        case proton
        case electron
    }
    
    // MARK: - Methods
    // The default nucleus is proton.
    init() {
        self.nucleus = NMRNucleus()
        frequencyLarmor = fieldExternal * nucleus.γ
        frequencyProton = fieldExternal * NMRLarmor.gammaProton
        frequencyElectron = fieldExternal * NMRLarmor.gammaElectron
    }
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
        frequencyLarmor = fieldExternal * nucleus.γ
        frequencyProton = fieldExternal * NMRLarmor.gammaProton
        frequencyElectron = fieldExternal * NMRLarmor.gammaElectron
    }
    
    public mutating func update(_ parameter: Parameter, to value: Double) -> Bool {
        switch parameter {
        case .field:
            fieldExternal = value
            frequencyLarmor = larmorFrequency(γ: nucleus.γ, at: fieldExternal)
            frequencyProton = larmorFrequency(γ: NMRLarmor.gammaProton, at: fieldExternal)
            frequencyElectron = larmorFrequency(γ: NMRLarmor.gammaElectron, at: fieldExternal)
        case .larmor:
            frequencyLarmor = value
            fieldExternal = externalField(γ: nucleus.γ, at: value)
            frequencyProton = larmorFrequency(γ: NMRLarmor.gammaProton, at: fieldExternal)
            frequencyElectron = larmorFrequency(γ: NMRLarmor.gammaElectron, at: fieldExternal)
        case .proton:
            frequencyProton = value
            fieldExternal = externalField(γ: NMRLarmor.gammaProton, at: value)
            frequencyLarmor = larmorFrequency(γ: nucleus.γ, at: fieldExternal)
            frequencyElectron = larmorFrequency(γ: NMRLarmor.gammaElectron, at: fieldExternal)
        case .electron:
            frequencyElectron = value
            fieldExternal = externalField(γ: NMRLarmor.gammaElectron, at: value)
            frequencyProton = larmorFrequency(γ: NMRLarmor.gammaProton, at: fieldExternal)
            frequencyLarmor = larmorFrequency(γ: nucleus.γ, at: fieldExternal)
        }
        
        return true
    }
    
    // Convinience Methods
    private mutating func larmorFrequency(γ: Double, at fieldExternal: Double) -> Double {
        return fieldExternal * γ
    }
    
    private mutating func externalField(γ: Double, at frequency: Double) -> Double {
        return frequency / γ
    }
    
    public func describe() -> String {
        let string1 = "External field = \(fieldExternal) T"
        let string2 = "Larmor Frequency = \(frequencyLarmor) MHz"
        let string3 = "Larmor Frequency of Proton = \(frequencyProton) MHz"
        let string4 = "Larmor Frequency of Electron = \(frequencyElectron) GHz"
        return string1 + "\n" + string2 + "\n" + string3 + "\n" + string4
    }
}
