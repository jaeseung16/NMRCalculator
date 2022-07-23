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
    
    init() {
        nucleus = NMRNucleus()
        
        externalField = larmorFrequencyCalculator.magneticField
        larmorFrequency = larmorFrequencyCalculator.larmorFrequency
        protonFrequency = larmorFrequencyCalculator.protonFrequency
        electronFrequency = larmorFrequencyCalculator.electroFrequency
       
        numberOfTimeDataPoints = Double(timeDomainCalculator.numberOfPoints)
        acquisitionDuration = timeDomainCalculator.acqusitionTime
        dwellTime = timeDomainCalculator.dwellInμs
        
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
            if nucleus != oldValue {
                larmorFrequencyCalculator.set(gyromagneticRatio: nucleus.γ)
                larmorFrequency = larmorFrequencyCalculator.larmorFrequency
                updateAmplitude1InT()
                
                nucleusUpdated.toggle()
            }
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
                larmorFrequencyCalculator.set(magneticField: externalField)
                larmorFrequency = larmorFrequencyCalculator.larmorFrequency
            }
        }
    }
    
    @Published var larmorFrequency: Double {
        didSet {
            if larmorFrequency != oldValue {
                larmorFrequencyCalculator.set(larmorFrequency: larmorFrequency)
                externalField = larmorFrequencyCalculator.magneticField
                protonFrequency = larmorFrequencyCalculator.protonFrequency
                electronFrequency = larmorFrequencyCalculator.electroFrequency
            }
        }
    }
    
    @Published var protonFrequency: Double {
        didSet {
            if protonFrequency != oldValue {
                larmorFrequencyCalculator.set(protonFrequency: protonFrequency)
                externalField = larmorFrequencyCalculator.magneticField
            }
        }
    }
    
    @Published var electronFrequency: Double {
        didSet {
            if electronFrequency != oldValue {
                larmorFrequencyCalculator.set(electronFrequency: electronFrequency)
                externalField = larmorFrequencyCalculator.magneticField
            }
        }
    }
  
    // MARK: - Signal
    
    @Published var numberOfTimeDataPoints: Double {
        didSet {
            if numberOfTimeDataPoints != oldValue {
                timeDomainCalculator.set(numberOfPoints: Int(numberOfTimeDataPoints))
                dwellTime = timeDomainCalculator.dwellInμs
            }
        }
    }
    
    @Published var acquisitionDuration: Double {
        didSet {
            if acquisitionDuration != oldValue {
                timeDomainCalculator.set(acqusitionTime: acquisitionDuration)
                dwellTime = timeDomainCalculator.dwellInμs
            }
        }
    }
    
    @Published var dwellTime: Double {
        didSet {
            if dwellTime != oldValue {
                timeDomainCalculator.set(dwellInμs: dwellTime)
                acquisitionDuration = timeDomainCalculator.acqusitionTime
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
