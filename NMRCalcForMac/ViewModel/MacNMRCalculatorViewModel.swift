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
    let frequencyDomainCalculator = FrequencyDomainCalculator.shared
    let pulseCalculator = PulseCalculator.shared
    let ernstAngleCalculator = ErnstAngleCalculator.shared
    
    let proton = NMRNucleus()
    
    init() {
        let B0 = 1.0
        nucleus = NMRNucleus()
        externalField = B0
        larmorFrequency = larmorFrequencyCalculator.ω(γ: NMRCalcConstants.gammaProton, B: B0)
        protonFrequency = larmorFrequencyCalculator.ωProton(at: B0)
        electronFrequency = larmorFrequencyCalculator.ωElectron(at: B0)
        
        let numberOfDataPoints = 1000.0
        let duration = 1.0
        let spectralRange = 1.0
        
        numberOfTimeDataPoints = numberOfDataPoints
        acquisitionDuration = duration
        dwellTime = timeDomainCalculator.calculateDwellTime(totalDuration: duration, numberOfDataPoints: numberOfDataPoints)
        
        numberOfFrequencyDataPoints = numberOfDataPoints
        spectralWidth = spectralRange
        frequencyResolution = frequencyDomainCalculator.calculateFrequencyResolution(spectralWidth: spectralRange, numberOfDataPoints: numberOfDataPoints)
        
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
        duration2 = p2
        flipAngle2 = φ2
        amplitude2 = amp2
        
        relativePower = 20.0 * log10(abs(amp2/amp1))
        
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
                updateFrequencyResolution()
            }
        }
    }
    
    @Published var spectralWidth: Double {
        didSet {
            if spectralWidth != oldValue {
                updateFrequencyResolution()
            }
        }
    }
    
    @Published var frequencyResolution: Double {
        didSet {
            if frequencyResolution != oldValue {
                numberOfFrequencyDataPoints = frequencyDomainCalculator.calcualteNumberOfDataPoints(spectralWidth: spectralWidth, frequencyResolution: frequencyResolution)
            }
        }
    }
    
    private func updateDwellTime() {
        dwellTime = timeDomainCalculator.calculateDwellTime(totalDuration: acquisitionDuration, numberOfDataPoints: numberOfTimeDataPoints)
    }
    
    private func updateFrequencyResolution() {
        frequencyResolution = frequencyDomainCalculator.calculateFrequencyResolution(spectralWidth: spectralWidth, numberOfDataPoints: numberOfFrequencyDataPoints)
    }

    // MARK: - Pulse
    
    @Published var duration1: Double {
        didSet {
            if duration1 != oldValue {
                amplitude1 = pulseCalculator.updateAmplitude(flipAngle: flipAngle1, duration: duration1)
                updateAmplitude1InT()
                updateRelativePower()
            }
        }
    }
    
    @Published var flipAngle1: Double {
        didSet {
            if flipAngle1 != oldValue {
                amplitude1 = pulseCalculator.updateAmplitude(flipAngle: flipAngle1, duration: duration1)
                updateAmplitude1InT()
                updateRelativePower()
            }
        }
    }
    
    @Published var amplitude1: Double {
        didSet {
            if amplitude1 != oldValue {
                updateAmplitude1InT()
                duration1 = pulseCalculator.updateDuration(flipAngle: flipAngle1, amplitude: amplitude1)
                updateRelativePower()
            }
        }
    }
    
    @Published var amplitude1InT: Double {
        didSet {
            if amplitude1InT != oldValue {
                amplitude1 = amplitude1InT * γNucleus
                duration1 = pulseCalculator.updateDuration(flipAngle: flipAngle1, amplitude: amplitude1)
                updateRelativePower()
            }
        }
    }
    
    @Published var duration2: Double {
        didSet {
            if duration2 != oldValue {
                amplitude2 = pulseCalculator.updateAmplitude(flipAngle: flipAngle2, duration: duration2)
                updateRelativePower()
            }
        }
    }
    
    @Published var flipAngle2: Double {
        didSet {
            if flipAngle2 != oldValue {
                amplitude2 = pulseCalculator.updateAmplitude(flipAngle: flipAngle2, duration: duration2)
                updateRelativePower()
            }
        }
    }
    
    @Published var amplitude2: Double {
        didSet {
            if amplitude2 != oldValue {
                duration2 = pulseCalculator.updateDuration(flipAngle: flipAngle2, amplitude: amplitude2)
                updateRelativePower()
            }
        }
    }
    
    @Published var relativePower: Double {
        didSet {
            if relativePower != oldValue {
                amplitude2 = pulseCalculator.calculateAmplitude(dB: relativePower, reference: amplitude1)
                duration2 = pulseCalculator.updateDuration(flipAngle: flipAngle2, amplitude: amplitude2)
            }
        }
    }
    
    private func updateRelativePower() -> Void {
        relativePower = pulseCalculator.calculateDecibel(measured: amplitude2, reference: amplitude1)
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
                repetitionTime = ernstAngleCalculator.calculateRepetitionTime(relaxationTime: relaxationTime, ernstAngle: ernstAngle)
            }
        }
    }
    
}
