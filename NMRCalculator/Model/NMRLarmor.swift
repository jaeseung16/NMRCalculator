//
//  NMRLarmor.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/23/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRLarmor {
    // MARK:- Properties
    // Constants
    let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    let gammaElectron = 176.0859644 / 2 / Double.pi // in GHz/T
    
    // Variables
    var frequencyLarmor: Double = 0.0
    var fieldExternal: Double = 0.0
    var frequencyProton: Double = 0.0
    var frequencyElectron: Double = 0.0
    
    var nucleus: NMRNucleus
    
    
    // MARK: - Enumeration
    enum Parameters: String {
        case field
        case larmor
        case proton
        case electron
    }
    
    // MARK:- Methods
    init() {
        self.nucleus = NMRNucleus()
        let _ = self.setParameter("field", to: 1.0)
    }
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
    }
    
    mutating func setParameter(_ name: String, to value: Double) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .field:
            self.fieldExternal = value
        case .larmor:
            self.frequencyLarmor = value
            //self.fieldExternal = self.frequencyLarmor / self.nucleus.γ
            self.fieldExternal = self.externalField(γ: self.nucleus.γ, at: self.frequencyLarmor)
        case .proton:
            self.frequencyProton = value
            // self.fieldExternal = self.frequencyProton / self.gammaProton
            self.fieldExternal = self.externalField(γ: self.gammaProton, at: self.frequencyProton)
        case .electron:
            self.frequencyElectron = value
            // self.fieldExternal = self.frequencyElectron / self.gammaElectron
            self.fieldExternal = self.externalField(γ: self.gammaElectron, at: self.frequencyElectron)
        }
        
        return true
    }
    
    mutating func update(parameter name: String) -> Bool {
        guard let parameter = Parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .field:
            // self.fieldExternal = self.frequencyLarmor / self.nucleus.γ
            self.fieldExternal = self.externalField(γ: self.nucleus.γ, at: self.frequencyLarmor)
        case .larmor:
            //self.frequencyLarmor = self.fieldExternal * self.nucleus.γ
            self.frequencyLarmor = self.larmorFrequency(γ: self.nucleus.γ, at: self.fieldExternal)
        case .proton:
            // self.frequencyProton = self.fieldExternal * self.gammaProton
            self.frequencyProton = self.larmorFrequency(γ: self.gammaProton, at: self.fieldExternal)
        case .electron:
            self.frequencyElectron = self.larmorFrequency(γ: self.gammaElectron, at: self.fieldExternal)
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
        let string1 = "External field = \(self.fieldExternal) T"
        let string2 = "Larmor Frequency = \(self.frequencyLarmor) MHz"
        let string3 = "Larmor Frequency of Proton = \(self.frequencyProton) MHz"
        let string4 = "Larmor Frequency of Electron = \(self.frequencyElectron) MHz"
        
        return string1 + "\n" + string2 + "\n" + string3 + "\n" + string4
    }
    
}
