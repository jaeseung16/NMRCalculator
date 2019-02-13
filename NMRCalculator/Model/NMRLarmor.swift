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
    var frequencyLarmor: Double // in MHz
    var fieldExternal: Double = 1.0 // in T
    var frequencyProton: Double // in MHz
    var frequencyElectron: Double // in GHz
    
    var nucleus: NMRNucleus
    
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
    
    mutating func set(parameter name: Parameter, to value: Double) -> Bool {
        switch name {
        case .field:
            fieldExternal = value
        case .larmor:
            frequencyLarmor = value
            fieldExternal = externalField(γ: nucleus.γ, at:frequencyLarmor)
        case .proton:
            self.frequencyProton = value
            fieldExternal = externalField(γ: NMRLarmor.gammaProton, at: frequencyProton)
        case .electron:
            frequencyElectron = value
            fieldExternal = externalField(γ: NMRLarmor.gammaElectron, at: frequencyProton)
        }
        
        return true
    }
    
    mutating func update(parameter name: Parameter) -> Bool {
        switch name {
        case .field:
            fieldExternal = externalField(γ: nucleus.γ, at: frequencyLarmor)

        case .larmor:
            frequencyLarmor = larmorFrequency(γ: nucleus.γ, at: fieldExternal)
            
        case .proton:
            frequencyProton = larmorFrequency(γ: NMRLarmor.gammaProton, at: fieldExternal)
            
        case .electron:
            frequencyElectron = larmorFrequency(γ: NMRLarmor.gammaElectron, at: fieldExternal)
        }
        
        return true
    }
    
    // Convinience Methods
    mutating func larmorFrequency(γ: Double, at fieldExternal: Double) -> Double {
        return fieldExternal * γ
    }
    
    mutating func externalField(γ: Double, at frequency: Double) -> Double {
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
