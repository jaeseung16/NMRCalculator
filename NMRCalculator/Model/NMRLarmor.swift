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
    let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    let gammaElectron = 176.0859644 / 2 / Double.pi // in GHz/T
    
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
        frequencyProton = fieldExternal * gammaProton
        frequencyElectron = fieldExternal * gammaElectron
    }
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
        frequencyLarmor = fieldExternal * nucleus.γ
        frequencyProton = fieldExternal * gammaProton
        frequencyElectron = fieldExternal * gammaElectron
    }
    
    mutating func set(parameter name: String, to value: Double) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .field:
            fieldExternal = value
        case .larmor:
            frequencyLarmor = value
            fieldExternal = frequencyLarmor / nucleus.γ
        case .proton:
            self.frequencyProton = value
            fieldExternal = frequencyProton / gammaProton
        case .electron:
            frequencyElectron = value
            fieldExternal = frequencyElectron / gammaElectron
        }
        
        return true
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameter(rawValue: name) else { return false }
        
        switch parameter {
        case .field:
            fieldExternal = frequencyLarmor / nucleus.γ

        case .larmor:
            frequencyLarmor = fieldExternal * nucleus.γ
            
        case .proton:
            frequencyProton = fieldExternal * gammaProton
            
        case .electron:
            frequencyElectron = fieldExternal * gammaElectron
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
