//
//  NMRCalc2ViewModel.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os

class NMRCalculator2: ObservableObject {
    private let logger = Logger()
    
    private let periodicTable = NMRPeriodicTableData()
    
    private let nucleus: NMRNucleus
    
    private let larmorFrequencyCalculator: LarmorFrequencyMagneticFieldConverter
    private let timeDomainCalculator: DwellAcquisitionTimeConverter
    private let frequencyDomainCalculator: SpectralWidthFrequencyResolutionConverter
    private let ernstAngleCalculator: ErnstAngleCalculator
    private let decibelCalculator: DecibelCalculator
    
    private let pulse1: Pulse
    private let pulse2: Pulse
    
    private var commands: [NMRCalcCommandName: NMRCalcCommand]
    
    private var commandsForPulse1: Set<NMRCalcCommandName>
    private var commandsForPulse2: Set<NMRCalcCommandName>
    
    @Published var updated = false
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
        
        self.larmorFrequencyCalculator = LarmorFrequencyMagneticFieldConverter(magneticField: 1.0, gyromagneticRatio: nucleus.γ)
        commands = [NMRCalcCommandName: NMRCalcCommand]()
        commands[.larmorFrequency] = UpdateLarmorFrequency(larmorFrequencyCalculator)
        commands[.magneticField] = UpdateMagneticField(larmorFrequencyCalculator)
        commands[.protonFrequency] = UpdateProtonFrequency(larmorFrequencyCalculator)
        commands[.electronFrequency] = UpdateElectronFrequency(larmorFrequencyCalculator)
        
        self.ernstAngleCalculator = ErnstAngleCalculator(repetitionTime: 1.0, relaxationTime: 1.0)
        commands[.ernstAngle] = UpdateErnstAngle(ernstAngleCalculator)
        commands[.repetitionTime] = UpdateRepetitionTime(ernstAngleCalculator)
        commands[.relaxationTime] = UpdateRelaxationTime(ernstAngleCalculator)
        
        self.timeDomainCalculator = DwellAcquisitionTimeConverter(acqusitionTime: 1.0, numberOfPoints: 1000)
        commands[.acquisitionTime] = UpdateAcquisitionTime(timeDomainCalculator)
        commands[.dwellTime] = UpdateDwellTime(timeDomainCalculator)
        commands[.dwellTimeInμs] = UpdateDwellTimeInμs(timeDomainCalculator)
        commands[.acquisitionSize] = UpdateAcquisitionSize(timeDomainCalculator)
        
        self.frequencyDomainCalculator = SpectralWidthFrequencyResolutionConverter(spectralWidth: 1000.0, numberOfPoints: 1000)
        commands[.spectrumSize] = UpdateSpectrumSize(frequencyDomainCalculator)
        commands[.frequencyResolution] = UpdateFrequencyResolution(frequencyDomainCalculator)
        commands[.spectralWidth] = UpdateSpectralWidth(frequencyDomainCalculator)
        commands[.spectralWidthInkHz] = UpdateSpectralWidthInkHz(frequencyDomainCalculator)
        
        self.pulse1 = Pulse(duration: 10.0, flipAngle: 90.0)
        commands[.pulse1Duration] = UpdatePulseDuration(pulse1)
        commands[.pulse1Amplitude] = UpdatePulseAmplitude(pulse1)
        commands[.pulse1FlipAngle] = UpdatePulseFlipAngle(pulse1)
        self.commandsForPulse1 = [.pulse1Duration, .pulse1Amplitude, .pulse1FlipAngle]
        
        self.pulse2 = Pulse(duration: 1000.0, flipAngle: 90.0)
        commands[.pulse2Duration] = UpdatePulseDuration(pulse2)
        commands[.pulse2Amplitude] = UpdatePulseAmplitude(pulse2)
        commands[.pulse2FlipAngle] = UpdatePulseFlipAngle(pulse2)
        self.commandsForPulse2 = [.pulse2Duration, .pulse2Amplitude, .pulse2FlipAngle]
        
        self.decibelCalculator = DecibelCalculator()
        amplitude1InT = self.pulse1.amplitude / NMRCalcConstants.gammaProton
        relativePower = self.decibelCalculator.dB(measuredAmplitude: self.pulse2.amplitude, referenceAmplitude: self.pulse1.amplitude)
    }
    
    var nucleusName: String {
        nucleus.nameNucleus
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
            
            if commandsForPulse1.contains(commandName) {
                updateAmplitude1InT()
                updateRelativePower()
            } else if commandsForPulse2.contains(commandName) {
                updateRelativePower()
            }
            
            updated.toggle()
        } else {
            logger.log("Can't find any command named \(commandName.rawValue, privacy: .public)")
        }
    }
    
    // MARK: - Larmor frequency
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
