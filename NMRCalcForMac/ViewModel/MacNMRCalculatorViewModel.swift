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
    
    // Signal
    
    @Published var numberOfTimeDataPoint: Double?
    @Published var acquisitionDuration: Double?
    @Published var dwellTime: Double?
    @Published var numberOfFrequencyDataPoint: Double?
    @Published var spectralWidth: Double?
    @Published var frequencyResolution: Double?
    
    private let secToμs: Double = 1000000.0
    private var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    private let kHzToHz: Double = 1000.0
    
    private func updateDwellTime() {
        dwellTime = acquisitionDuration! * secToμs / numberOfTimeDataPoint!
    }
    
    func numberOfTimeDataPointUpdated() {
        if acquisitionDuration == nil {
            acquisitionDuration = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1000.0
        }
        
        updateDwellTime()
    }
    
    func acquisitionDurationUpdated() {
        if acquisitionDuration == nil {
            acquisitionDuration = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1000.0
        }
        
        updateDwellTime()
    }
    
    func dwellTimeUpdated() {
        if dwellTime == nil {
            dwellTime = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1.0
        }
        
        acquisitionDuration = numberOfTimeDataPoint! * (dwellTime! * μsToSec)
    }
    
    private func updateFrequencyResolution() {
        frequencyResolution =  spectralWidth! * kHzToHz / numberOfFrequencyDataPoint!
    }
    
    func numberOfFrequencyDataPointUpdated() {
        if numberOfFrequencyDataPoint == nil {
            numberOfFrequencyDataPoint = 1000.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        updateFrequencyResolution()
    }
    
    func spectralWidthUpdated() {
        if numberOfFrequencyDataPoint == nil {
            numberOfFrequencyDataPoint = 1000.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        updateFrequencyResolution()
    }
    
    func frequencyResolutionUpdated() {
        if frequencyResolution == nil {
            frequencyResolution = 1.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        numberOfFrequencyDataPoint = spectralWidth! * kHzToHz / frequencyResolution!
    }
    
}
