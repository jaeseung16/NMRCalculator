//
//  MacNMRCalculator.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/2/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Foundation

class MacNMRCalculator: ObservableObject {
    public static let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    public static let gammaElectron = -176.0859644 / 2 / Double.pi // in GHz/T
    
    @Published var nucleus: NMRNucleus?
    @Published var larmorFrequency: Double?
    @Published var protonFrequency: Double?
    @Published var electronFrequency: Double?
    @Published var externalField: Double?
    
    func nucluesUpdated() {
        guard let nucleus = self.nucleus else {
            return
        }
        let gyromaneticRatio = Double(nucleus.gyromagneticRatio)!
        
        self.externalField = self.externalField ?? 1.0
        self.larmorFrequency = gyromaneticRatio * self.externalField!
        self.protonFrequency = self.externalField! * MacNMRCalculator.gammaProton
        self.electronFrequency = self.externalField! * MacNMRCalculator.gammaElectron
    }
    
    func externalFieldUpdated() {
        guard let externalField = self.externalField, let nucleus = self.nucleus else {
            return
        }
        
        self.larmorFrequency = externalField * Double(nucleus.gyromagneticRatio)!
        self.protonFrequency = externalField * MacNMRCalculator.gammaProton
        self.electronFrequency  = externalField * MacLamorFrequencyView.gammaElectron
    }
    
    func larmorFrequencyUpdated() {
        guard let larmorFrequency = self.larmorFrequency, let nucleus = self.nucleus else {
            return
        }
        
        let gyromaneticRatio = Double(nucleus.gyromagneticRatio)!
        
        self.externalField = larmorFrequency / gyromaneticRatio
        self.protonFrequency = self.externalField! * MacNMRCalculator.gammaProton
        self.electronFrequency  = self.externalField! * MacLamorFrequencyView.gammaElectron
    }
    
    func protonFrequencyUpdated() {
        guard let protonFrequency = self.protonFrequency, let nucleus = self.nucleus else {
            return
        }
        
        let gyromaneticRatio = Double(nucleus.gyromagneticRatio)!
        
        self.externalField = protonFrequency / MacNMRCalculator.gammaProton
        self.larmorFrequency = self.externalField! * gyromaneticRatio
        self.electronFrequency  = self.externalField! * MacLamorFrequencyView.gammaElectron
    }
    
    func electronFrequencyUpdated() {
        guard let electronFrequency = self.electronFrequency, let nucleus = self.nucleus else {
            return
        }
        
        let gyromaneticRatio = Double(nucleus.gyromagneticRatio)!
        
        self.externalField = electronFrequency / MacNMRCalculator.gammaElectron
        self.larmorFrequency = self.externalField! * gyromaneticRatio
        self.protonFrequency  = self.externalField! * MacLamorFrequencyView.gammaProton
    }
    
}
