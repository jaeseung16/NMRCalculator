//
//  MacNMRCalculatorViewModel.swift
//  NMRCalc
//
//  Created by Jae Seung Lee on 3/9/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import Combine
import os

class MacNMRCalculatorViewModel: ObservableObject {
    static let logger = Logger()
    
    let larmorFrequencyCalculator = LarmorFrequencyMagneticFieldConverter(magneticField: 1.0, gyromagneticRatio: NMRNucleus().γ)
    let timeDomainCalculator = DwellAcquisitionTimeConverter(acqusitionTime: 1.0, numberOfPoints: 1000)
    let frequencyDomainCalculator = SpectralWidthFrequencyResolutionConverter(spectralWidth: 1000.0, numberOfPoints: 1000)
    let ernstAngleCalculator = ErnstAngleCalculator(repetitionTime: 1.0, relaxationTime: 1.0)
    let decibelCalculator = DecibelCalculator()
    
    let proton = NMRNucleus()
    
    let pulse1 = Pulse(duration: 10.0, flipAngle: 90.0)
    let pulse2 = Pulse(duration: 1000.0, flipAngle: 90.0)
    
    var commands = [NMRCalcCommandName: NMRCalcCommand]()

    init() {
        nucleus = NMRNucleus()
       
        amplitude1InT = pulse1.amplitude / NMRCalcConstants.gammaProton
        relativePower = decibelCalculator.dB(measuredAmplitude: pulse2.amplitude, referenceAmplitude: pulse1.amplitude)

        commands[.larmorFrequency] = UpdateLarmorFrequency(larmorFrequencyCalculator)
        commands[.magneticField] = UpdateMagneticField(larmorFrequencyCalculator)
        commands[.protonFrequency] = UpdateProtonFrequency(larmorFrequencyCalculator)
        commands[.electronFrequency] = UpdateElectronFrequency(larmorFrequencyCalculator)
        
        commands[.acquisitionTime] = UpdateAcquisitionTime(timeDomainCalculator)
        commands[.dwellTime] = UpdateDwellTime(timeDomainCalculator)
        commands[.dwellTimeInμs] = UpdateDwellTimeInμs(timeDomainCalculator)
        commands[.acquisitionSize] = UpdateAcquisitionSize(timeDomainCalculator)
        
        commands[.spectrumSize] = UpdateSpectrumSize(frequencyDomainCalculator)
        commands[.frequencyResolution] = UpdateFrequencyResolution(frequencyDomainCalculator)
        commands[.spectralWidth] = UpdateSpectralWidth(frequencyDomainCalculator)
        commands[.spectralWidthInkHz] = UpdateSpectralWidthInkHz(frequencyDomainCalculator)
        
        commands[.pulse1Duration] = UpdatePulseDuration(pulse1)
        commands[.pulse1Amplitude] = UpdatePulseAmplitude(pulse1)
        commands[.pulse1FlipAngle] = UpdatePulseFlipAngle(pulse1)
        
        commands[.pulse2Duration] = UpdatePulseDuration(pulse2)
        commands[.pulse2Amplitude] = UpdatePulseAmplitude(pulse2)
        commands[.pulse2FlipAngle] = UpdatePulseFlipAngle(pulse2)
        
        commands[.ernstAngle] = UpdateErnstAngle(ernstAngleCalculator)
        commands[.repetitionTime] = UpdateRepetitionTime(ernstAngleCalculator)
        commands[.relaxationTime] = UpdateRelaxationTime(ernstAngleCalculator)
        
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
    
    func update(_ commandName: NMRCalcCommandName, to value: Double) -> Void {
        if let command = commands[commandName] {
            command.execute(with: value)
            toggle(commandName)
        } else {
            MacNMRCalculatorViewModel.logger.log("Can't find any command named \(commandName.rawValue, privacy: .public)")
        }
    }
    
    func toggle(_ commandName: NMRCalcCommandName) {
        switch commandName {
        case .larmorFrequency, .magneticField, .protonFrequency, .electronFrequency:
            nucleusUpdated.toggle()
        case .dwellTime, .dwellTimeInμs, .acquisitionSize, .acquisitionTime:
            timeDomainUpdated.toggle()
        case .spectrumSize, .spectralWidth, .spectralWidthInkHz, .frequencyResolution:
            frequencyDomainUpdated.toggle()
        case .pulse1Duration, .pulse1Amplitude, .pulse1FlipAngle:
            updateAmplitude1InT()
            updateRelativePower()
            pulse1Updated.toggle()
        case .pulse2Duration, .pulse2Amplitude, .pulse2FlipAngle:
            updateRelativePower()
            pulse2Updated.toggle()
        case .ernstAngle, .repetitionTime, .relaxationTime:
            ernstAngleUpdated.toggle()
        default:
            return
        }
    }
    
    // MARK: - Larmor frequency
    
    @Published var nucleusUpdated = false
    
    var nucleus: NMRNucleus {
        didSet {
            if nucleus != oldValue {
                larmorFrequencyCalculator.set(gyromagneticRatio: nucleus.γ)
                nucleusUpdated.toggle()
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
    
    var larmorFrequency: Double {
        larmorFrequencyCalculator.larmorFrequency
    }
    
    var protonFrequency: Double {
        larmorFrequencyCalculator.protonFrequency
    }
    
    var electronFrequency: Double {
        larmorFrequencyCalculator.electroFrequency
    }
  
    // MARK: - Signal
    
    @Published var timeDomainUpdated = false
    
    var numberOfTimeDataPoints: Double {
        Double(timeDomainCalculator.numberOfPoints)
    }
    
    var acquisitionDuration: Double {
        timeDomainCalculator.acqusitionTime
    }
    
    var dwellTime: Double {
        timeDomainCalculator.dwellInμs
    }
    
    @Published var frequencyDomainUpdated = false
    
    var numberOfFrequencyDataPoints: Double {
        Double(frequencyDomainCalculator.numberOfPoints)
    }
    
    var spectralWidth: Double {
        frequencyDomainCalculator.spectralWidthInkHz
    }
    
    var frequencyResolution: Double {
        frequencyDomainCalculator.frequencyResolution
    }

    // MARK: - Pulse
    
    @Published var pulse1Updated = false
    @Published var pulse2Updated = false
    
    var duration1: Double {
        pulse1.duration
    }
    
    var flipAngle1: Double {
        pulse1.flipAngle
    }

    var amplitude1: Double {
        pulse1.amplitude
    }

    var amplitude1InT: Double
    
    func update(pulse1AmplitudeInT: Double) -> Void {
        update(.pulse1Amplitude, to: pulse1AmplitudeInT * γNucleus)
        updateAmplitude1InT()
        updateRelativePower()
        updateFromPulse1()
    }
    
    var duration2: Double {
        pulse2.duration
    }
    
    var flipAngle2: Double {
        pulse2.flipAngle
    }
    
    var amplitude2: Double {
        pulse2.amplitude
    }
    
    var relativePower: Double {
        didSet {
            if relativePower != oldValue {
                update(.pulse2Amplitude, to: decibelCalculator.amplitude(dB: relativePower, referenceAmplitude: amplitude1))
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
    @Published var ernstAngleUpdated = false
    
    var repetitionTime: Double {
        ernstAngleCalculator.repetitionTime
    }
    
    var relaxationTime: Double {
        ernstAngleCalculator.relaxationTime
    }
    
    var ernstAngle: Double {
        ernstAngleCalculator.ernstAngle
    }
    
}
