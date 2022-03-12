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
        $nucleus
            .receive(on: DispatchQueue.main, options: nil)
            .sink { _ in
                if self.amplitude1InT != nil {
                    self.updateAmplitude1InT()
                }
            }
            .store(in: &subscriptions)
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

    // Pulse
    @Published var duration1: Double?
    @Published var flipAngle1: Double?
    @Published var amplitude1: Double?
    @Published var amplitude1InT: Double?
    @Published var duration2: Double?
    @Published var flipAngle2: Double?
    @Published var amplitude2: Double?
    @Published var relativePower: Double?
    
    private func updateAmplitude(flipAngle: Double, duration: Double) -> Double {
        return (flipAngle / 360.0) / (duration * μsToSec)
    }
    
    private func updateDuration(flipAngle: Double, amplitude: Double) -> Double {
        return (flipAngle / 360.0) / amplitude * secToμs
    }
    
    private func calculateRelativePower() -> Void {
         if let amp1 = amplitude1 {
             if let amp2 = amplitude2 {
                 relativePower = 20.0 * log10(abs(amp2/amp1))
             }
         }
     }
    
    func duration1Updated() -> Void {
        if flipAngle1 == nil {
            flipAngle1 = 90.0
        }
        
        if duration1 == nil {
            duration1 = 10
        }
        
        amplitude1 = updateAmplitude(flipAngle: flipAngle1!, duration: duration1!)
        updateAmplitude1InT()
        calculateRelativePower()
    }
    
    func duration2Updated() -> Void {
        if flipAngle2 == nil {
            flipAngle2 = 90.0
        }
        
        if duration2 == nil {
            duration2 = 10
        }
        
        amplitude2 = updateAmplitude(flipAngle: flipAngle2!, duration: duration2!)
        calculateRelativePower()
    }
    
    func flipAngle1Updated() -> Void {
        if flipAngle1 == nil {
            flipAngle1 = 90.0
        }
        
        if duration1 == nil {
            duration1 = 10.0
        }
        
        amplitude1 = updateAmplitude(flipAngle: flipAngle1!, duration: duration1!)
        updateAmplitude1InT()
        calculateRelativePower()
    }
    
    func flipAngle2Updated() -> Void {
        if flipAngle2 == nil {
            flipAngle2 = 90.0
        }
        
        if duration2 == nil {
            duration2 = 10.0
        }
        
        amplitude2 = updateAmplitude(flipAngle: flipAngle2!, duration: duration2!)
        calculateRelativePower()
    }
    
    func amplitude1Updated() -> Void {
        if flipAngle1 == nil {
            flipAngle1 = 90.0
        }
        
        if amplitude1 == nil {
            amplitude1 = 25000
        }
        
        updateAmplitude1InT()
        duration1 = updateDuration(flipAngle: flipAngle1!, amplitude: amplitude1!)
        calculateRelativePower()
    }
    
    private func updateAmplitude1InT() {
        if let nucleus = nucleus, let gyromaneticRatio = Double(nucleus.gyromagneticRatio) {
            amplitude1InT = amplitude1! / gyromaneticRatio
        }
    }
    
    func amplitude2Updated() -> Void {
        if flipAngle2 == nil {
            flipAngle2 = 90.0
        }
        
        if amplitude2 == nil {
            amplitude2 = 25000
        }
        
        duration2 = updateDuration(flipAngle: flipAngle2!, amplitude: amplitude2!)
        calculateRelativePower()
    }

    func relativePowerUpdated() -> Void {
        guard let amp1 = amplitude1 else {
            return
        }
        
        amplitude2 = pow(10.0, 1.0 * relativePower! / 20.0) * amp1
    }
    
    // Ernst
    @Published var repetitionTime: Double?
    @Published var relaxationTime: Double?
    @Published var ernstAngle: Double?
    
    private let radianToDegree = 180.0 / Double.pi
    private var degreeToRadian: Double {
        return 1.0 / radianToDegree
    }
    
    private func updateErnstAngle(repetitionTime: Double, relaxationTime: Double) -> Double {
        return acos( exp(-1.0 * repetitionTime / relaxationTime) ) * radianToDegree
    }
    
    func repetitionTimeUpdated() -> Void {
        if relaxationTime == nil {
            relaxationTime = 1.0
        }
        
        if repetitionTime == nil {
            repetitionTime = 1.0
        }
        
        ernstAngle = updateErnstAngle(repetitionTime: repetitionTime!, relaxationTime: relaxationTime!)
    }
    
    func relaxationTimeUpdated() -> Void {
        if relaxationTime == nil {
            relaxationTime = 1.0
        }
        
        if repetitionTime == nil {
            repetitionTime = 1.0
        }
        
        ernstAngle = updateErnstAngle(repetitionTime: repetitionTime!, relaxationTime: relaxationTime!)
    }
    
    func ernstAngleUpdated() -> Void {
        if relaxationTime == nil {
            relaxationTime = 1.0
        }
        
        repetitionTime = -1.0 * relaxationTime! * log(cos(ernstAngle! * degreeToRadian))
    }
}