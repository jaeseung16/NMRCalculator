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
    let frequencyDomainCalculator = SpectralWidthFrequencyResolutionConverter(spectralWidth: 1000.0, numberOfPoints: 1000)
    let ernstAngleCalculator = ErnstAngleCalculator()
    let decibelCalculator = DecibelCalculator()
    
    let proton = NMRNucleus()
    
    let pulse1 = Pulse(duration: 10.0, flipAngle: 90.0)
    let pulse2 = Pulse(duration: 1000.0, flipAngle: 90.0)
    
    init() {
        let B0 = 1.0
        nucleus = NMRNucleus()
        externalField = B0
        larmorFrequency = larmorFrequencyCalculator.ω(γ: NMRCalcConstants.gammaProton, B: B0)
        protonFrequency = larmorFrequencyCalculator.ωProton(at: B0)
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: B0)
        
        let numberOfDataPoints = 1000.0
        let duration = 1.0
       
        numberOfTimeDataPoints = numberOfDataPoints
        acquisitionDuration = duration
        dwellTime = timeDomainCalculator.calculateDwellTime(totalDuration: duration, numberOfDataPoints: numberOfDataPoints)
        
        numberOfFrequencyDataPoints = Double(frequencyDomainCalculator.numberOfPoints)
        spectralWidth = frequencyDomainCalculator.spectralWidthInkHz
        frequencyResolution = frequencyDomainCalculator.frequencyResolution
        
        duration1 = pulse1.duration
        flipAngle1 = pulse1.flipAngle
        amplitude1 = pulse1.amplitude
        amplitude1InT = pulse1.amplitude / NMRCalcConstants.gammaProton
        
        duration2 = pulse2.duration
        flipAngle2 = pulse2.flipAngle
        amplitude2 = pulse2.amplitude
        
        relativePower = decibelCalculator.dB(measuredAmplitude: pulse2.amplitude, referenceAmplitude: pulse1.amplitude)
        
        let τ = 1.0
        let T1 = 1.0
        repetitionTime = τ
        relaxationTime = T1
        ernstAngle = ernstAngleCalculator.calculateErnstAngle(repetitionTime: τ, relaxationTime: T1)
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
    
    @Published var nucleus: NMRNucleus {
        didSet {
            larmorFrequency = larmorFrequencyCalculator.ω(γ: γNucleus, B: externalField)
            updateAmplitude1InT()
            
            nucleusUpdated.toggle()
        }
    }
    
    var γNucleus: Double {
        guard let γNucleus = Double(nucleus.gyromagneticRatio) else {
            return NMRCalcConstants.gammaProton
        }
        return γNucleus
    }
    
    @Published var externalField: Double {
        didSet {
            if externalField != oldValue {
                updateLarmorFrequency()
                updateProtonFrequency()
                updateElectronFrequency()
            }
        }
    }
    
    @Published var larmorFrequency: Double {
        didSet {
            if larmorFrequency != oldValue {
                externalField = larmorFrequencyCalculator.B0(larmorFrequency: larmorFrequency, γ: γNucleus)
                updateProtonFrequency()
                updateElectronFrequency()
            }
        }
    }
    
    @Published var protonFrequency: Double {
        didSet {
            if protonFrequency != oldValue {
                externalField = larmorFrequencyCalculator.B0(larmorFrequency: protonFrequency, γ: NMRCalcConstants.gammaProton)
                updateLarmorFrequency()
                updateElectronFrequency()
            }
        }
    }
    
    @Published var electronFrequency: Double {
        didSet {
            if electronFrequency != oldValue {
                externalField = larmorFrequencyCalculator.B0(larmorFrequency: electronFrequency, γ: NMRCalcConstants.gammaElectron)
                updateLarmorFrequency()
                updateProtonFrequency()
            }
        }
    }
    
    private func updateLarmorFrequency() {
        larmorFrequency = larmorFrequencyCalculator.ω(γ: γNucleus, B: externalField)
    }
    
    private func updateProtonFrequency() {
        protonFrequency = larmorFrequencyCalculator.ωProton(at: externalField)
    }
    
    private func updateElectronFrequency() {
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: externalField)
    }
  
    // MARK: - Signal
    
    @Published var numberOfTimeDataPoints: Double {
        didSet {
            if numberOfTimeDataPoints != oldValue {
                updateDwellTime()
            }
        }
    }
    
    @Published var acquisitionDuration: Double {
        didSet {
            if acquisitionDuration != oldValue {
                updateDwellTime()
            }
        }
    }
    
    @Published var dwellTime: Double {
        didSet {
            if dwellTime != oldValue {
                acquisitionDuration = timeDomainCalculator.calculateTotalDuration(dwellTime: dwellTime, numberOfDataPoints: numberOfTimeDataPoints)
            }
        }
    }
    
    @Published var numberOfFrequencyDataPoints: Double {
        didSet {
            if numberOfFrequencyDataPoints != oldValue {
                frequencyDomainCalculator.set(numberOfPoints: Int(numberOfFrequencyDataPoints))
                frequencyResolution = frequencyDomainCalculator.frequencyResolution
            }
        }
    }
    
    @Published var spectralWidth: Double {
        didSet {
            if spectralWidth != oldValue {
                frequencyDomainCalculator.set(spectralWidthInkHz: spectralWidth)
                frequencyResolution = frequencyDomainCalculator.frequencyResolution
            }
        }
    }
    
    @Published var frequencyResolution: Double {
        didSet {
            if frequencyResolution != oldValue {
                frequencyDomainCalculator.set(frequencyResolution: frequencyResolution)
                numberOfFrequencyDataPoints = Double(frequencyDomainCalculator.numberOfPoints)
            }
        }
    }
    
    private func updateDwellTime() {
        dwellTime = timeDomainCalculator.calculateDwellTime(totalDuration: acquisitionDuration, numberOfDataPoints: numberOfTimeDataPoints)
    }

    // MARK: - Pulse
    
    @Published var duration1: Double {
        didSet {
            if duration1 != oldValue {
                pulse1.set(duration: duration1)
                amplitude1 = pulse1.amplitude
                updateAmplitude1InT()
                updateRelativePower()
            }
        }
    }
    
    @Published var flipAngle1: Double {
        didSet {
            if flipAngle1 != oldValue {
                pulse1.set(flipAngle: flipAngle1)
                amplitude1 = pulse1.amplitude
                updateAmplitude1InT()
                updateRelativePower()
            }
        }
    }
    
    @Published var amplitude1: Double {
        didSet {
            if amplitude1 != oldValue {
                pulse1.set(amplitude: amplitude1)
                duration1 = pulse1.duration
                updateAmplitude1InT()
                updateRelativePower()
            }
        }
    }
    
    @Published var amplitude1InT: Double {
        didSet {
            if amplitude1InT != oldValue {
                amplitude1 = amplitude1InT * γNucleus
                pulse1.set(amplitude: amplitude1)
                duration1 = pulse1.duration
                updateRelativePower()
            }
        }
    }
    
    @Published var duration2: Double {
        didSet {
            if duration2 != oldValue {
                pulse2.set(duration: duration2)
                amplitude2 = pulse2.amplitude
                updateRelativePower()
            }
        }
    }
    
    @Published var flipAngle2: Double {
        didSet {
            if flipAngle2 != oldValue {
                pulse2.set(flipAngle: flipAngle2)
                amplitude2 = pulse2.amplitude
                updateRelativePower()
            }
        }
    }
    
    @Published var amplitude2: Double {
        didSet {
            if amplitude2 != oldValue {
                pulse2.set(amplitude: amplitude2)
                duration2 = pulse2.duration
                updateRelativePower()
            }
        }
    }
    
    @Published var relativePower: Double {
        didSet {
            if relativePower != oldValue {
                amplitude2 = decibelCalculator.amplitude(dB: relativePower, referenceAmplitude: amplitude1)
            }
        }
    }
    
    private func updateRelativePower() -> Void {
        relativePower = decibelCalculator.dB(measuredAmplitude: amplitude2, referenceAmplitude: amplitude1)
    }
    
    private func updateAmplitude1InT() {
        amplitude1InT = amplitude1 / γNucleus
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
