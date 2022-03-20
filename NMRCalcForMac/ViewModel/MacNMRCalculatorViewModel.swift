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
    let larmorFrequencyCalculator = LarmorFrequencyCalculator.shared
    let timeDomainCalculator = TimeDomainCalculator.shared
    let pulseCalculator = PulseCalculator.shared
    let ernstAngleCalculator = ErnstAngleCalculator.shared
    
    let proton = NMRNucleus()
    
    @Published var nucleusUpdated = false
    
    @Published var nucleus: NMRNucleus {
        didSet {
            externalField = externalField
            larmorFrequency = larmorFrequencyCalculator.ω(γ: γNucleus, B: externalField)
            protonFrequency = larmorFrequencyCalculator.ωProton(at: externalField)
            electronFrequency = larmorFrequencyCalculator.ωElectron(at: externalField)
            updateAmplitude1InT()
            
            nucleusUpdated.toggle()
        }
    }
    
    @Published var larmorFrequency: Double
    @Published var protonFrequency: Double
    @Published var electronFrequency: Double
    @Published var externalField: Double
    
    private var γNucleus: Double {
        guard let γNucleus = Double(nucleus.gyromagneticRatio) else {
            return NMRCalcConstants.gammaProton
        }
        return γNucleus
    }
    
    init() {
        nucleus = NMRNucleus()
        externalField = 1.0
        larmorFrequency = larmorFrequencyCalculator.ω(γ: NMRCalcConstants.gammaProton, B: 1.0)
        protonFrequency = larmorFrequencyCalculator.ωProton(at: 1.0)
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: 1.0)
        
        numberOfTimeDataPoint = 1000.0
        acquisitionDuration = 1.0
        dwellTime = timeDomainCalculator.calculateDwellTime(totalDuration: 1.0, numberOfDataPoints: 1000.0)
        
        numberOfFrequencyDataPoint = 1000.0
        spectralWidth = 1.0
        frequencyResolution = 1.0 * MacNMRCalculatorViewModel.kHzToHz / 1000.0
        
        let p1 = 10.0
        let φ1 = 90.0
        let amp1 = pulseCalculator.updateAmplitude(flipAngle: φ1, duration: p1)
        duration1 = p1
        flipAngle1 = φ1
        amplitude1 = amp1
        amplitude1InT = amp1 / NMRCalcConstants.gammaProton
        
        let p2 = 1000.0
        let φ2 = 90.0
        let amp2 = pulseCalculator.updateAmplitude(flipAngle: φ2, duration: p2)
        duration2 = φ2
        flipAngle2 = 90.0
        amplitude2 = amp2
        
        relativePower = 20.0 * log10(abs(amp2/amp1))
        
        repetitionTime = 1.0
        relaxationTime = 1.0
        ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: 1.0, relaxationTime: 1.0)
    }
    
    func validateExternalField() -> Bool {
        return abs(externalField) <= 1000.0
    }
    
    func externalFieldUpdated() {
        larmorFrequency = larmorFrequencyCalculator.ω(γ: γNucleus, B: externalField)
        protonFrequency = larmorFrequencyCalculator.ωProton(at: externalField)
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: externalField)
    }
    
    func larmorFrequencyUpdated() {
        externalField = larmorFrequency / γNucleus
        protonFrequency = larmorFrequencyCalculator.ωProton(at: externalField)
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: externalField)
    }
    
    func protonFrequencyUpdated() {
        externalField = protonFrequency / NMRCalcConstants.gammaProton
        larmorFrequency = larmorFrequencyCalculator.ω(γ: γNucleus, B: externalField)
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: externalField)
    }
    
    func electronFrequencyUpdated() {
        externalField = electronFrequency / NMRCalcConstants.gammaElectron
        larmorFrequency = larmorFrequencyCalculator.ω(γ: γNucleus, B: externalField)
        protonFrequency = larmorFrequencyCalculator.ωProton(at: externalField)
    }
  
    // Signal
    @Published var numberOfTimeDataPoint: Double
    @Published var acquisitionDuration: Double
    @Published var dwellTime: Double
    @Published var numberOfFrequencyDataPoint: Double
    @Published var spectralWidth: Double
    @Published var frequencyResolution: Double
    
    private static let kHzToHz: Double = 1000.0
    
    private func updateDwellTime() {
        dwellTime = timeDomainCalculator.calculateDwellTime(totalDuration: acquisitionDuration, numberOfDataPoints: numberOfTimeDataPoint)
    }
    
    func validateNumberOfTimeDataPoint() -> Bool {
        return numberOfTimeDataPoint >= 1.0
    }
    
    func numberOfTimeDataPointUpdated() {
        updateDwellTime()
    }
    
    func validateAcquisitionDuration() -> Bool {
        return acquisitionDuration > 0.0
    }
    
    func acquisitionDurationUpdated() {
        updateDwellTime()
    }
    
    func validateDwellTime() -> Bool {
        return dwellTime > 0.0
    }
    
    func dwellTimeUpdated() {
        acquisitionDuration = timeDomainCalculator.calculateTotalDuration(dwellTime: dwellTime, numberOfDataPoints: numberOfTimeDataPoint)
    }
    
    private func updateFrequencyResolution() {
        frequencyResolution =  spectralWidth * MacNMRCalculatorViewModel.kHzToHz / numberOfFrequencyDataPoint
    }
    
    func validateNumberOfFrequencyDataPoint() -> Bool {
        return numberOfFrequencyDataPoint >= 1
    }
    
    func numberOfFrequencyDataPointUpdated() {
        updateFrequencyResolution()
    }
    
    func validateSpectralWidth() -> Bool {
        return spectralWidth > 0.0
    }
    
    func spectralWidthUpdated() {
        updateFrequencyResolution()
    }
    
    func validateFrequencyResolution() -> Bool {
        return frequencyResolution > 0.0
    }
    
    func frequencyResolutionUpdated() {
        numberOfFrequencyDataPoint = spectralWidth * MacNMRCalculatorViewModel.kHzToHz / frequencyResolution
    }

    // Pulse
    @Published var duration1: Double
    @Published var flipAngle1: Double
    @Published var amplitude1: Double
    @Published var amplitude1InT: Double
    @Published var duration2: Double
    @Published var flipAngle2: Double
    @Published var amplitude2: Double
    @Published var relativePower: Double
    
    private func updateRelativePower() -> Void {
        relativePower = pulseCalculator.calculateDecibel(measured: amplitude2, reference: amplitude1)
    }
    
    func validateDuration1() -> Bool {
        return duration1 >= 0.0
    }
    
    func duration1Updated() -> Void {
        amplitude1 = pulseCalculator.updateAmplitude(flipAngle: flipAngle1, duration: duration1)
        updateAmplitude1InT()
        updateRelativePower()
    }
    
    func validateDuration2() -> Bool {
        return duration2 >= 0.0
    }
    
    func duration2Updated() -> Void {
        amplitude2 = pulseCalculator.updateAmplitude(flipAngle: flipAngle2, duration: duration2)
        updateRelativePower()
    }
    
    func validateFlipAngle1() -> Bool {
        return flipAngle1 >= 0.0
    }
    
    func flipAngle1Updated() -> Void {
        amplitude1 = pulseCalculator.updateAmplitude(flipAngle: flipAngle1, duration: duration1)
        updateAmplitude1InT()
        updateRelativePower()
    }
    
    func validateFlipAngle2() -> Bool {
        return flipAngle2 >= 0.0
    }
    
    func flipAngle2Updated() -> Void {
        amplitude2 = pulseCalculator.updateAmplitude(flipAngle: flipAngle2, duration: duration2)
        updateRelativePower()
    }
    
    func validateAmplitude1() -> Bool {
        return amplitude1 >= 0.0
    }
    
    func amplitude1Updated() -> Void {
        updateAmplitude1InT()
        duration1 = pulseCalculator.updateDuration(flipAngle: flipAngle1, amplitude: amplitude1)
        updateRelativePower()
    }
    
    func validateAmplitude1InT() -> Bool {
        return amplitude1InT >= 0.0
    }
    
    func amplitude1InTUpdated() -> Void {
        amplitude1 = amplitude1InT * γNucleus
        duration1 = pulseCalculator.updateDuration(flipAngle: flipAngle1, amplitude: amplitude1)
        updateRelativePower()
    }
    
    private func updateAmplitude1InT() {
        amplitude1InT = amplitude1 / γNucleus
    }
    
    func validateAmplitude2() -> Bool {
        return amplitude2 >= 0.0
    }
    
    func amplitude2Updated() -> Void {
        duration2 = pulseCalculator.updateDuration(flipAngle: flipAngle2, amplitude: amplitude2)
        updateRelativePower()
    }

    func relativePowerUpdated() -> Void {
        amplitude2 = pulseCalculator.calculateAmplitude(dB: relativePower, reference: amplitude1)
        duration2 = pulseCalculator.updateDuration(flipAngle: flipAngle2, amplitude: amplitude2)
    }
    
    // Ernst
    @Published var repetitionTime: Double
    @Published var relaxationTime: Double
    @Published var ernstAngle: Double
    
    func validateErnstAngle() -> Bool {
        return ernstAngle >= 0.0
    }
    
    func validateRepetitionTime() -> Bool {
        return repetitionTime >= 0.0
    }
    
    func repetitionTimeUpdated() -> Void {
        ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
    }
    
    func validateRelaxationTime() -> Bool {
        return relaxationTime >= 0.0
    }
    
    func relaxationTimeUpdated() -> Void {
        ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
    }
    
    func ernstAngleUpdated() -> Void {
        repetitionTime = ernstAngleCalculator.calculateRepetitionTime(relaxationTime: relaxationTime, ernstAngle: ernstAngle)
    }
}
