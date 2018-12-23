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
    
    enum NMRCalcCategory {
        case resonance;
        case acquisition;
        case spectrum;
        case pulse1;
        case pulse2;
        case ernstAngle;
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
    
    func setErnstParameter(_ name: NMRErnstAngle.Parameter, to value: Double) -> Bool {
        if value > 0 {
            switch name {
            case .repetition:
                repetitionTime = value
                return true
            case .relaxation:
                relaxationTime = value
                return true
            case .angleErnst:
                if value <= Double.pi / 2.0 {
                    angleErnst = value
                    return true
                }
            }
        }
        
        return false
    }
    
    func evaluateErnstParameter(_ name: NMRErnstAngle.Parameter) -> Bool {
        switch name {
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
        case .angleErnst:
            if relaxationTime != nil && repetitionTime != nil {
                angleErnst = acos(exp(-1.0 * repetitionTime! / relaxationTime! ))
                return true
            }
        }
        
        return false
    }
    
    func setParameter(_ name: String, in category: NMRCalcCategory, to value: Double) -> Bool {
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
            guard let name = NMRErnstAngle.Parameter(rawValue: name) else { return false }
            return setErnstParameter(name, to: value)
        }
        
    }
    
    func evaluate(parameter name: String, in category: NMRCalcCategory) -> Bool {
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
            guard let ernstAngle = NMRErnstAngle.Parameter(rawValue: name) else { return false }
            return evaluateErnstParameter(ernstAngle)
        }
    }
}

// MARK: - Convenience methods
extension NMRCalc {
    func updateParameter(_ name: String, in category: NMRCalcCategory, to value: Double, and name2: String, completionHandler: @escaping (_ error: String?) -> Void) {
        guard evaluate(parameter: name2, in: category) else {
            completionHandler("Cannot update \(name2).")
            return
        }
        
        completionHandler(nil)
    }
    
    func updateLarmor(_ name: String, to value: Double, completionHandler: @escaping (_ error: String?) -> Void) {
        let category = NMRCalcCategory.resonance
        
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
