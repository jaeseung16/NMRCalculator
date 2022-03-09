//
//  MacNMRCalculatorViewModel.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/9/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import Combine

class MacNMRCalculatorViewModel: ObservableObject {
    let proton = NMRNucleus()
    
    @Published var nucleus: NMRNucleus?
    @Published var larmorFrequency: Double?
    @Published var protonFrequency: Double?
    @Published var electronFrequency: Double?
    @Published var externalField: Double?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init() {
     
    }
    
    func nucluesUpdated() {
        guard let nucleus = self.nucleus,
              let gyromaneticRatio = Double(nucleus.gyromagneticRatio)
        else {
            return
        }
        
        self.externalField = self.externalField ?? 1.0
        self.larmorFrequency = ω(γ: gyromaneticRatio, B: self.externalField!)
        self.protonFrequency = ω(γ: NMRCalcConstants.gammaProton, B: self.externalField!)
        self.electronFrequency = ω(γ: NMRCalcConstants.gammaElectron, B: self.externalField!)
    }
    
    func validateExternalField() {
        guard let externalField = self.externalField else {
            return
        }

        if externalField < -1000.0 {
            self.externalField = -1000.0
        } else if externalField > 1000.0 {
            self.externalField = 1000.0
        }
    }
    
    func externalFieldUpdated() {
        guard let externalField = self.externalField,
              let nucleus = self.nucleus,
              let gyromaneticRatio = Double(nucleus.gyromagneticRatio)
        else {
            return
        }
        
        self.larmorFrequency = ω(γ: gyromaneticRatio, B: externalField)
        self.protonFrequency = ω(γ: NMRCalcConstants.gammaProton, B: externalField)
        self.electronFrequency = ω(γ: NMRCalcConstants.gammaElectron, B: externalField)
    }
    
    func larmorFrequencyUpdated() {
        guard let larmorFrequency = self.larmorFrequency,
              let nucleus = self.nucleus,
              let gyromaneticRatio = Double(nucleus.gyromagneticRatio)
        else {
            return
        }
        
        self.externalField = larmorFrequency / gyromaneticRatio
        self.protonFrequency = ω(γ: NMRCalcConstants.gammaProton, B: self.externalField!)
        self.electronFrequency = ω(γ: NMRCalcConstants.gammaElectron, B: self.externalField!)
    }
    
    func protonFrequencyUpdated() {
        guard let protonFrequency = self.protonFrequency,
              let nucleus = self.nucleus,
              let gyromaneticRatio = Double(nucleus.gyromagneticRatio)
        else {
            return
        }
        
        self.externalField = protonFrequency / NMRCalcConstants.gammaProton
        self.larmorFrequency = ω(γ: gyromaneticRatio, B: self.externalField!)
        self.electronFrequency = ω(γ: NMRCalcConstants.gammaElectron, B: self.externalField!)
    }
    
    func electronFrequencyUpdated() {
        guard let electronFrequency = self.electronFrequency,
              let nucleus = self.nucleus,
              let gyromaneticRatio = Double(nucleus.gyromagneticRatio)
        else {
            return
        }
        
        self.externalField = electronFrequency / NMRCalcConstants.gammaElectron
        self.larmorFrequency = ω(γ: gyromaneticRatio, B: self.externalField!)
        self.protonFrequency = ω(γ: NMRCalcConstants.gammaProton, B: self.externalField!)
    }
    
    private func ω(γ: Double, B: Double) -> Double {
        return γ * B
    }
    
}
