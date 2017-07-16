//
//  NMRCalc.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRCalc {
    
    // MARK: Properties
    
    var nucleus: Nucleus?
    
    var acqNMR: NMRfid?
    var specNMR: NMRSpectrum?
    var pulseNMR: [NMRPulse?]
    
    var frequencyLarmor: Double?
    var fieldExternal: Double?
    var frequencyProton: Double?
    var frequencyElectron: Double?
    
    var relativepower: Double?
    
    var repetitionTime: Double?
    var relaxationTime: Double?
    var angleErnst: Double?
    
    var gyromagneticratio: Double? {
        get {
            return nucleus?.γ
        }
    }
    
    let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    let gammaElectron = 176.0859644 / 2 / Double.pi // in GHz/T
    
    // MARK: Methods
    
    init() {
        acqNMR = NMRfid()
        specNMR = NMRSpectrum()
        pulseNMR = [NMRPulse]()
    }
    
    convenience init(nucleus: Nucleus) {
        self.init()
        self.nucleus = nucleus
    }
    
    // MARK: Enum for resonance frequency
    
    enum resonance: String {
        case field
        case larmor
        case proton
        case electron
    }
    
    
    // MARK: Setting parameters for the time domain
    
    enum acq_parameters: String {
        case size
        case duration
        case dwell
    }
    
    func set_ACQparameter(_ name: String, to value: Double) -> Bool {
        if let acq = acqNMR {
            return acq.parameterSet(of: name, to: value)
        }
        
        return false
        
    }
    
    func evaluate_ACQparameter(_ name: String) -> Bool {
        if let acq = acqNMR {
            return acq.update(name)
        }
        return false
    }
    
    // MARK: Setting parameters for the frequecny domain
    
    enum spec_parameters: String {
        case size
        case width
        case resolution
    }
    
    func set_specparameter(_ name: String, to_value: Double) -> Bool {
        if let spec = specNMR {
            return spec.set_parameter(name, to_value: to_value)
        }
        return false
    }
    
    func evaluate_specparameter(_ name: String) -> Bool {
        if let spec = specNMR {
            return spec.update(name)
        }
        return false
    }

    // MARK: Setting parameters for pulses
    
    enum pulse_parameters: String {
        case duration
        case flipangle
        case amplitude
    }
    
    func set_pulseparameter(_ name: String, of number: Int, to_value: Double) -> Bool {
        
        if let pulse = pulseNMR[number] {
            return pulse.set_parameter(name: name, to_value: to_value)
        }
        return false
        
    }
    
    func evaluate_pulseparameter(_ name: String, of number: Int) -> Bool {
        
        if let pulse = pulseNMR[number] {
            return pulse.update(name: name)
        }
        
        return false
    }
    
    
    func calculate_dB() -> Bool {
        
        if let amp1 = pulseNMR[0]?.amplitude {
            if let amp2 = pulseNMR[1]?.amplitude {
                relativepower = 20.0 * log10( abs(amp2 / amp1) )
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK: Ernst angle
    
    enum ernst_parameters: String {
        case repetition
        case relaxation
        case angle
    }
    
    func set_ernstparameter(_ name: String, to value: Double) -> Bool {
        if value > 0 {
            if let ernst = ernst_parameters(rawValue: name) {
                switch ernst {
                case .repetition:
                    repetitionTime = value
                    return true
                case .relaxation:
                    relaxationTime = value
                    return true
                case .angle:
                    if value <= Double.pi / 2.0 {
                        angleErnst = value
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func evaluate_ernstparameter(_ name: String) -> Bool {
        
        if let ernst = ernst_parameters(rawValue: name) {
            switch ernst {
            case .repetition:
                if relaxationTime != nil && angleErnst != nil {
                    repetitionTime = -1.0 * relaxationTime! * log( cos(angleErnst!) )
                    return true
                }
            case .relaxation:
                if repetitionTime != nil && angleErnst != nil {
                    relaxationTime = -1.0 * repetitionTime! / log( cos(angleErnst!) )
                    return true
                }
            case .angle:
                if relaxationTime != nil && repetitionTime != nil {
                    angleErnst = acos(exp(-1.0 * repetitionTime! / relaxationTime! ))
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK:
    
    enum nmrCalc_category: String {
        case resonance
        case acquisition
        case spectrum
        case ernstAngle
    }
    
    func setparameter(in category: String, of name: String, to value: Double) -> Bool {
        if let cat = nmrCalc_category(rawValue: category) {
            switch cat {
            case .resonance:
                return updateResonance(with: name, equal: value)
            case .acquisition:
                if let acq = acqNMR {
                    return acq.parameterSet(of: name, to: value)
                }
            case .spectrum:
                if let spec = specNMR {
                    return spec.set_parameter(name, to_value: value)
                }
            case .ernstAngle:
                return set_ernstparameter(name, to: value)
            }
        }
        return false
    }
}

// MARK: Methods for resonance frequency
extension NMRCalc {
    func updateResonance(with name: String, equal value: Double) -> Bool {
        guard let name = resonance(rawValue: name), let nucleus = self.nucleus else {
            return false
        }
        
        switch name {
        case .field:
            self.fieldExternal = value
        case .larmor:
            self.fieldExternal = value / nucleus.γ!
        case .proton:
            self.fieldExternal = value / gammaProton
        case .electron:
            self.fieldExternal = value / gammaElectron
        }
        
        return larmorFrequency(at: self.fieldExternal!)
    }
    
    func larmorFrequency(at B0: Double) -> Bool {
        
        guard let gamma = nucleus?.γ else {
            print("Check whether there are values for the external field and gyromagnetic ratio.")
            return false
        }
        self.fieldExternal = B0
        self.frequencyLarmor = B0 * gamma
        self.frequencyProton = B0 * gammaProton
        self.frequencyElectron = B0 * gammaElectron
        
        return true
        
    }

}
