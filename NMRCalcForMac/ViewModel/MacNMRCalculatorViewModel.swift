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
    let larmorFrequencyCalculator = LarmorFrequencyMagneticFieldConverter(magneticField: 1.0, gyromagneticRatio: NMRNucleus().γ)
    let timeDomainCalculator = DwellAcquisitionTimeConverter(acqusitionTime: 1.0, numberOfPoints: 1000)
    let frequencyDomainCalculator = SpectralWidthFrequencyResolutionConverter(spectralWidth: 1000.0, numberOfPoints: 1000)
    let ernstAngleCalculator = ErnstAngleCalculator()
    let decibelCalculator = DecibelCalculator()
    
    let proton = NMRNucleus()
    
    let pulse1 = Pulse(duration: 10.0, flipAngle: 90.0)
    let pulse2 = Pulse(duration: 1000.0, flipAngle: 90.0)
    
    let updateMagneticField: NMRCalcCommand
    let updateLarmorFrequency: NMRCalcCommand
    let updateProtonFrequency: NMRCalcCommand
    let updateElectronFrequency: NMRCalcCommand
    
    let updateAcquisitionTime: NMRCalcCommand
    let updateDwellTime: NMRCalcCommand
    let updateDwellTimeInμs: NMRCalcCommand
    let updateAcquisitionSize: NMRCalcCommand
    
    let updateSpectrumSize: NMRCalcCommand
    let updateFrequencyResolution: NMRCalcCommand
    let updateSpectralWidth: NMRCalcCommand
    let updateSpectralWidthInkHz: NMRCalcCommand
    
    let updatePulse1Duration: NMRCalcCommand
    let updatePulse2Duration: NMRCalcCommand
    let updatePulse1FlipAngle: NMRCalcCommand
    let updatePulse2FlipAngle: NMRCalcCommand
    let updatePulse1Amplitude: NMRCalcCommand
    let updatePulse2Amplitude: NMRCalcCommand
    
    init() {
        nucleus = NMRNucleus()
       
        amplitude1InT = pulse1.amplitude / NMRCalcConstants.gammaProton
        relativePower = decibelCalculator.dB(measuredAmplitude: pulse2.amplitude, referenceAmplitude: pulse1.amplitude)
        
        let τ = 1.0
        let T1 = 1.0
        repetitionTime = τ
        relaxationTime = T1
        ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: τ, relaxationTime: T1)
        
        updateLarmorFrequency = UpdateLarmorFrequency(larmorFrequencyCalculator)
        updateMagneticField = UpdateMagneticField(larmorFrequencyCalculator)
        updateProtonFrequency = UpdateProtonFrequency(larmorFrequencyCalculator)
        updateElectronFrequency = UpdateElectronFrequency(larmorFrequencyCalculator)
        
        updateAcquisitionTime = UpdateAcquisitionTime(timeDomainCalculator)
        updateDwellTime = UpdateDwellTime(timeDomainCalculator)
        updateDwellTimeInμs = UpdateDwellTimeInμs(timeDomainCalculator)
        updateAcquisitionSize = UpdateAcquisitionSize(timeDomainCalculator)
        
        updateSpectrumSize = UpdateSpectrumSize(frequencyDomainCalculator)
        updateFrequencyResolution = UpdateFrequencyResolution(frequencyDomainCalculator)
        updateSpectralWidth = UpdateSpectralWidth(frequencyDomainCalculator)
        updateSpectralWidthInkHz = UpdateSpectralWidthInkHz(frequencyDomainCalculator)
        
        updatePulse1Duration = UpdatePulseDuration(pulse1)
        updatePulse2Duration = UpdatePulseDuration(pulse2)
        updatePulse1FlipAngle = UpdatePulseFlipAngle(pulse1)
        updatePulse2FlipAngle = UpdatePulseFlipAngle(pulse2)
        updatePulse1Amplitude = UpdatePulseAmplitude(pulse1)
        updatePulse2Amplitude = UpdatePulseAmplitude(pulse2)
    }
    
    // MARK: - Validation
    
    func isPositive(_ value: Double) -> Bool {
        return value > 0.0
    }
    
    func isNonNegative(_ value: Double) -> Bool {
        return value >= 0.0
    }
    
    func validate(externalField B0: Double) -> Bool {
        return abs(B0) <= 1000.0
    }
    
    func validate(numberOfDataPoints: Double) -> Bool {
        return numberOfDataPoints >= 1.0
    }
    
    func validate(ernstAngle: Double) -> Bool {
        return ernstAngle > 0.0 && ernstAngle < 90.0
    }
    
    
    // MARK: - Larmor frequency
    
    @Published var nucleusUpdated = false
    
    var nucleus: NMRNucleus {
        didSet {
            if nucleus != oldValue {
                larmorFrequencyCalculator.set(gyromagneticRatio: nucleus.γ)
                updateFromLarmorFrequencyCalculator()
                updateAmplitude1InT()
            }
        }
    }
    
    var γNucleus: Double {
        guard let γNucleus = Double(nucleus.gyromagneticRatio) else {
            return NMRCalcConstants.gammaProton
        }
        return γNucleus
    }
    
    var externalField: Double {
        larmorFrequencyCalculator.magneticField
    }
    
    func update(externalField: Double) -> Void {
        updateMagneticField.execute(with: externalField)
        updateFromLarmorFrequencyCalculator()
    }
    
    var larmorFrequency: Double {
        larmorFrequencyCalculator.larmorFrequency
    }
    
    func update(larmorFrequency: Double) -> Void {
        updateLarmorFrequency.execute(with: larmorFrequency)
        updateFromLarmorFrequencyCalculator()
    }
    
    var protonFrequency: Double {
        larmorFrequencyCalculator.protonFrequency
    }
    
    func update(protonFrequency: Double) -> Void {
        updateProtonFrequency.execute(with: protonFrequency)
        updateFromLarmorFrequencyCalculator()
    }
    
    var electronFrequency: Double {
        larmorFrequencyCalculator.electroFrequency
    }
    
    func update(electronFrequency: Double) -> Void {
        updateElectronFrequency.execute(with: electronFrequency)
        updateFromLarmorFrequencyCalculator()
    }
    
    func updateFromLarmorFrequencyCalculator() -> Void {
        nucleusUpdated.toggle()
    }
  
    // MARK: - Signal
    
    @Published var timeDomainUpdated = false
    
    var numberOfTimeDataPoints: Double {
        Double(timeDomainCalculator.numberOfPoints)
    }
    
    func update(acquisitionSize: Double) -> Void {
        updateAcquisitionSize.execute(with: acquisitionSize)
        updateFromTimeDomainCalculator()
    }
    
    var acquisitionDuration: Double {
        timeDomainCalculator.acqusitionTime
    }
    
    func update(acquisitionDuration: Double) -> Void {
        updateAcquisitionTime.execute(with: acquisitionDuration)
        updateFromTimeDomainCalculator()
    }
    
    var dwellTime: Double {
        timeDomainCalculator.dwellInμs
    }
    
    func update(dwellTime: Double) -> Void {
        updateDwellTimeInμs.execute(with: dwellTime)
        updateFromTimeDomainCalculator()
    }
    
    func updateFromTimeDomainCalculator() -> Void {
        timeDomainUpdated.toggle()
    }
    
    @Published var frequencyDomainUpdated = false
    
    var numberOfFrequencyDataPoints: Double {
        Double(frequencyDomainCalculator.numberOfPoints)
    }
    
    func update(numberOfFrequencyDataPoints: Double) -> Void {
        updateSpectrumSize.execute(with: numberOfFrequencyDataPoints)
        updateFromFrequencyDomainCalculator()
    }
    
    var spectralWidth: Double {
        frequencyDomainCalculator.spectralWidthInkHz
    }

    func update(spectralWidth: Double) -> Void {
        updateSpectralWidthInkHz.execute(with: spectralWidth)
        updateFromFrequencyDomainCalculator()
    }
    
    var frequencyResolution: Double {
        frequencyDomainCalculator.frequencyResolution
    }
    
    func update(frequencyResolution: Double) -> Void {
        updateFrequencyResolution.execute(with: frequencyResolution)
        updateFromFrequencyDomainCalculator()
    }
    
    func updateFromFrequencyDomainCalculator() -> Void {
        frequencyDomainUpdated.toggle()
    }

    // MARK: - Pulse
    
    @Published var pulse1Updated = false
    @Published var pulse2Updated = false
    
    var duration1: Double {
        pulse1.duration
    }
    
    func update(pulse1Duration: Double) -> Void {
        updatePulse1Duration.execute(with: pulse1Duration)
        updateAmplitude1InT()
        updateRelativePower()
        updateFromPulse1()
    }
    
    var flipAngle1: Double {
        pulse1.flipAngle
    }
    
    func update(pulse1FlipAngle: Double) -> Void {
        updatePulse1FlipAngle.execute(with: pulse1FlipAngle)
        updateAmplitude1InT()
        updateRelativePower()
        updateFromPulse1()
    }
    
    var amplitude1: Double {
        pulse1.amplitude
    }
    
    func update(pulse1Amplitude: Double) -> Void {
        updatePulse1Amplitude.execute(with: pulse1Amplitude)
        updateAmplitude1InT()
        updateRelativePower()
        updateFromPulse1()
    }
    
    var amplitude1InT: Double
    
    func update(pulse1AmplitudeInT: Double) -> Void {
        updatePulse1Amplitude.execute(with: pulse1AmplitudeInT * γNucleus)
        updateAmplitude1InT()
        updateRelativePower()
        updateFromPulse1()
    }
    
    var duration2: Double {
        pulse2.duration
    }
    
    func update(pulse2Duration: Double) -> Void {
        updatePulse2Duration.execute(with: pulse2Duration)
        updateRelativePower()
        updateFromPulse2()
    }
    
    var flipAngle2: Double {
        pulse2.flipAngle
    }
    
    func update(pulse2FlipAngle: Double) -> Void {
        updatePulse2FlipAngle.execute(with: pulse2FlipAngle)
        updateRelativePower()
        updateFromPulse2()
    }
    
    var amplitude2: Double {
        pulse2.amplitude
    }
    
    func update(pulse2Amplitude: Double) -> Void {
        updatePulse2Amplitude.execute(with: pulse2Amplitude)
        updateRelativePower()
        updateFromPulse2()
    }
    
    @Published var relativePower: Double {
        didSet {
            if relativePower != oldValue {
                update(pulse2Amplitude: decibelCalculator.amplitude(dB: relativePower, referenceAmplitude: amplitude1))
            }
        }
    }
    
    private func updateRelativePower() -> Void {
        relativePower = decibelCalculator.dB(measuredAmplitude: amplitude2, referenceAmplitude: amplitude1)
    }
    
    private func updateAmplitude1InT() {
        amplitude1InT = amplitude1 / γNucleus
    }
    
    func updateFromPulse1() -> Void {
        pulse1Updated.toggle()
    }
    
    func updateFromPulse2() -> Void {
        pulse2Updated.toggle()
    }
    
    // MARK: - Ernst Angle
    @Published var repetitionTime: Double {
        didSet {
            if repetitionTime != oldValue {
                ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
            }
        }
    }
    
    @Published var relaxationTime: Double {
        didSet {
            if relaxationTime != oldValue {
                ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime)
            }
        }
    }
    
    @Published var ernstAngle: Double {
        didSet {
            if ernstAngle != oldValue {
                repetitionTime = ernstAngleCalculator.calculateRepetitionTime(ernstAngle: ernstAngle, relaxationTime: relaxationTime)
            }
        }
    }
    
}
