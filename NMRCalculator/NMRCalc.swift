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
    
    var nucleus: NMRNucleus?
    
    var larmorNMR: NMRLarmor?
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
        larmorNMR = NMRLarmor()
    }
    
    convenience init(nucleus: NMRNucleus) {
        self.init()
        self.nucleus = nucleus
        self.larmorNMR = NMRLarmor(nucleus: nucleus)
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
    
    // MARK: Setting parameters for the frequecny domain
    
    enum spec_parameters: String {
        case size
        case width
        case resolution
    }
    
    // MARK: Setting parameters for pulses
    
    enum pulse_parameters: String {
        case duration
        case flipangle
        case amplitude
    }
    
    func set_pulseparameter(_ name: String, of number: Int, to value: Double) -> Bool {
        
        if var pulse = pulseNMR[number] {
            return pulse.setParameter(parameter: name, to: value)
        }
        return false
        
    }
    
    func evaluate_pulseparameter(_ name: String, of number: Int) -> Bool {
        
        if var pulse = pulseNMR[number] {
            return pulse.updateParameter(name: name)
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
    
    enum calcCategory: String {
        case resonance
        case acquisition
        case spectrum
        case pulse1
        case pulse2
        case ernstAngle
    }
    
    func setParameter(_ name: String, in category: String, to value: Double) -> Bool {
        guard let category = calcCategory(rawValue: category) else { return false }
        
        switch category {
        case .resonance:
            guard var larmor = larmorNMR else { return false }
            
            return larmor.setParameter(parameter: name, to: value)
            
        case .acquisition:
            guard var acq = acqNMR else { return false }
            return acq.setFID(parameter: name, to: value)
            
        case .spectrum:
            guard var spec = specNMR else { return false }
            return spec.setSpectrum(parameter: name, to: value)
            
        case .pulse1:
            guard var pulse = pulseNMR[0] else { return false }
            return pulse.setParameter(parameter: name, to: value)
            
        case .pulse2:
            guard var pulse = pulseNMR[1] else { return false }
            return pulse.setParameter(parameter: name, to: value)
            
        case .ernstAngle:
            return set_ernstparameter(name, to: value)
        }
        
    }
    
    func evaluateParameter(_ name: String, in category: String) -> Bool {
        guard let category = calcCategory(rawValue: category) else { return false }
        
        switch category {
        case .resonance:
            guard var larmor = larmorNMR else { return false }
            
            return larmor.updateParameter(name: name)
            
        case .acquisition:
            guard var acq = acqNMR else { return false }
            return acq.updateParameters(name: name)
            
        case .spectrum:
            guard var spec = specNMR else { return false }
            return spec.updateParameter(name: name)
            
        case .pulse1:
            guard var pulse = pulseNMR[0] else { return false }
            return pulse.updateParameter(name: name)
            
        case .pulse2:
            guard var pulse = pulseNMR[1] else { return false }
            return pulse.updateParameter(name: name)
            
        case .ernstAngle:
            return false
        }
        
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
            self.fieldExternal = value / nucleus.γ
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

extension NMRCalc {
    func setACQ(parameter name: String, to value: Double) -> Bool {
        guard var acq = acqNMR else { return false }
        
        return acq.setFID(parameter: name, to: value)
    }
    
    func evaluateACQ(parameter name: String) -> Bool {
        guard var acq = acqNMR else { return false }
        
        return acq.updateParameters(name: name)
    }
    
    func setSpectrum(parameter name: String, to value: Double) -> Bool {
        guard var spec = specNMR else { return false }
        
        return spec.setSpectrum(parameter: name, to: value)
    }
    
    func evaluate_specparameter(_ name: String) -> Bool {
        guard var spec = specNMR else { return false }
        
        return spec.updateParameter(name: name)
    }
}
