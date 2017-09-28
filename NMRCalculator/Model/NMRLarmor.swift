//
//  NMRLarmor.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/23/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRLarmor {
    let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    let gammaElectron = 176.0859644 / 2 / Double.pi // in GHz/T
    
    var frequencyLarmor: Double = 0.0
    var fieldExternal: Double = 0.0
    var frequencyProton: Double = 0.0
    var frequencyElectron: Double = 0.0
    
    var nucleus: NMRNucleus
    
    enum parameters: String {
        case field
        case larmor
        case proton
        case electron
    }
    
    init() {
        self.nucleus = NMRNucleus()
    }
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
    }
    
    mutating func setParameter(parameter name: String, to value: Double) -> Bool {
        
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .field:
            self.fieldExternal = value
        case .larmor:
            self.frequencyLarmor = value
            self.fieldExternal = self.frequencyLarmor / self.nucleus.γ
        case .proton:
            self.frequencyProton = value
            self.fieldExternal = self.frequencyProton / self.gammaProton
        case .electron:
            self.frequencyElectron = value
            self.fieldExternal = self.frequencyElectron / self.gammaElectron
        }
        
        return true
    }
    
    mutating func updateParameter(name: String) -> Bool {
        
        guard let parameter = parameters(rawValue: name) else { return false }
        
        switch parameter {
        case .field:
            self.fieldExternal = self.frequencyLarmor / self.nucleus.γ

        case .larmor:
            self.frequencyLarmor = self.fieldExternal * self.nucleus.γ
            
        case .proton:
            self.frequencyProton = self.fieldExternal * self.gammaProton
            
        case .electron:
            self.frequencyElectron = self.fieldExternal * self.gammaElectron
        }
        
        return true
    }
    
    public func describe() -> String {
        let string1 = "External field = \(self.fieldExternal) T"
        
        let string2 = "Larmor Frequency = \(self.frequencyLarmor) MHz"
        
        let string3 = "Larmor Frequency of Proton = \(self.frequencyProton) MHz"
        
        let string4 = "Larmor Frequency of Electron = \(self.frequencyElectron) MHz"
        
        return string1 + "\n" + string2 + "\n" + string3 + "\n" + string4
    }
    
}
