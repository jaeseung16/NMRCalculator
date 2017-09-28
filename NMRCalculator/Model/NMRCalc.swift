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
    
    // MARK: Setting parameters for pulses

    
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
            guard larmorNMR != nil else { return false }
            return larmorNMR!.setParameter(parameter: name, to: value)
            
        case .acquisition:
            guard acqNMR != nil else { return false }
            return acqNMR!.setFID(parameter: name, to: value)
            
        case .spectrum:
            guard specNMR != nil else { return false }
            return specNMR!.setSpectrum(parameter: name, to: value)
            
        case .pulse1:
            guard pulseNMR[0] != nil else { return false }
            return pulseNMR[0]!.setParameter(parameter: name, to: value)
            
        case .pulse2:
            guard pulseNMR[1] != nil else { return false }
            return pulseNMR[1]!.setParameter(parameter: name, to: value)
            
        case .ernstAngle:
            return set_ernstparameter(name, to: value)
        }
        
    }
    
    func evaluateParameter(_ name: String, in category: String) -> Bool {
        guard let category = calcCategory(rawValue: category) else { return false }
        
        switch category {
        case .resonance:
            guard larmorNMR != nil else { return false }
            return larmorNMR!.updateParameter(name: name)
            
        case .acquisition:
            guard acqNMR != nil else { return false }
            return acqNMR!.updateParameters(name: name)
            
        case .spectrum:
            guard specNMR != nil else { return false }
            return specNMR!.updateParameter(name: name)
            
        case .pulse1:
            guard pulseNMR[0] != nil else { return false }
            return pulseNMR[0]!.updateParameter(name: name)
            
        case .pulse2:
            guard pulseNMR[1] != nil else { return false }
            return pulseNMR[1]!.updateParameter(name: name)
            
        case .ernstAngle:
            return evaluate_ernstparameter(name)
        }
        
    }
}
