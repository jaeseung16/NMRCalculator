//
//  NMRCalc.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/2/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRCalc {
    // MARK: Shared Instance
    static let shared: NMRCalc = {
        let instance = NMRCalc()
        instance.larmorNMR = NMRLarmor()
        instance.acqNMR = NMRfid()
        instance.specNMR = NMRSpectrum()
        instance.pulseNMR = [NMRPulse]()
        return instance
    }()
    
    // MARK: - Properties
    // MARK: Constants
    let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    let gammaElectron = 176.0859644 / 2 / Double.pi // in GHz/T
    
    // MARK: Variables
    var nucleus: NMRNucleus?
    
    var larmorNMR: NMRLarmor?
    var acqNMR: NMRfid?
    var specNMR: NMRSpectrum?
    var pulseNMR: [NMRPulse?]
    
    var relativepower: Double?
    
    var repetitionTime: Double?
    var relaxationTime: Double?
    var angleErnst: Double?
    
    // MARK:- enum
    enum ernst_parameters: String {
        case repetition
        case relaxation
        case angle
    }
    
    // MARK: - Methods
    init() {
        larmorNMR = NMRLarmor()
        acqNMR = NMRfid()
        specNMR = NMRSpectrum()
        pulseNMR = [NMRPulse]()
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
            return larmorNMR!.set(parameter: name, to: value)
            
        case .acquisition:
            guard acqNMR != nil else { return false }
            return acqNMR!.set(parameter: name, to: value)
            
        case .spectrum:
            guard specNMR != nil else { return false }
            return specNMR!.set(parameter: name, to: value)
            
        case .pulse1:
            guard pulseNMR[0] != nil else { return false }
            return pulseNMR[0]!.set(parameter: name, to: value)
            
        case .pulse2:
            guard pulseNMR[1] != nil else { return false }
            return pulseNMR[1]!.set(parameter: name, to: value)
            
        case .ernstAngle:
            return set_ernstparameter(name, to: value)
        }
        
    }
    
    func evaluate(parameter name: String, in category: String) -> Bool {
        guard let category = calcCategory(rawValue: category) else { return false }
        
        switch category {
        case .resonance:
            guard larmorNMR != nil else { return false }
            return larmorNMR!.update(parameter: name)
            
        case .acquisition:
            guard acqNMR != nil else { return false }
            return acqNMR!.update(parameter: name)
            
        case .spectrum:
            guard specNMR != nil else { return false }
            return specNMR!.update(parameter: name)
            
        case .pulse1:
            guard pulseNMR[0] != nil else { return false }
            return pulseNMR[0]!.update(parameter: name)
            
        case .pulse2:
            guard pulseNMR[1] != nil else { return false }
            return pulseNMR[1]!.update(parameter: name)
            
        case .ernstAngle:
            return evaluate_ernstparameter(name)
        }
    }
}

// MARK: - Convenience methods
extension NMRCalc {
    func updateParameter(_ name: String, in category: String, to value: Double, and name2: String, completionHandler: @escaping (_ error: String?) -> Void) {
        guard setParameter(name, in: category, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        guard evaluate(parameter: name2, in: category) else {
            completionHandler("Cannot update \(name2).")
            return
        }
        
        completionHandler(nil)
    }
    
    func updateLarmor(_ name: String, to value: Double, completionHandler: @escaping (_ error: String?) -> Void) {
        let category = "resonance"
        
        guard setParameter(name, in: category, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        switch name {
        case "larmor":
            guard evaluate(parameter: "proton", in: category), evaluate(parameter: "electron", in: category) else {
                completionHandler("Cannot update the proton and electron resonance frequencies.")
                return
            }
        case "field":
            guard evaluate(parameter: "larmor", in: category), evaluate(parameter: "proton", in: category), evaluate(parameter: "electron", in: category) else {
                completionHandler("Cannot update the proton and electron resonance frequencies.")
                return
            }
        case "proton":
            guard evaluate(parameter: "larmor", in: category), evaluate(parameter: "electron", in: category) else {
                completionHandler("Cannot update the proton and electron resonance frequencies.")
                return
            }
        case "electron":
            guard evaluate(parameter: "larmor", in: category), evaluate(parameter: "proton", in: category) else {
                completionHandler("Cannot update the proton and electron resonance frequencies.")
                return
            }
        default:
            completionHandler("Something is wrong.")
        }
        
        completionHandler(nil)
    }
}
