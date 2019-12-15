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
    var nucleus: NMRNucleus?
    
    var larmorNMR: NMRLarmor?
    var acqNMR: NMRfid?
    var specNMR: NMRSpectrum?
    var pulseNMR: [NMRPulse?]
    var ernstAngle: NMRErnstAngle?
    
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
        nucleus = NMRNucleus()
        larmorNMR = NMRLarmor()
        acqNMR = NMRfid()
        specNMR = NMRSpectrum()
        pulseNMR = [NMRPulse]()
        ernstAngle = NMRErnstAngle()
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
            return ernstAngle?.set(parameter: name, to: value) ?? false
        }
        
        return false
    }
    
    func evaluateErnstParameter(_ name: NMRErnstAngle.Parameter) -> Bool {
        return ernstAngle?.update(parameter: name) ?? false
    }
    
    func setParameter(_ name: String, in category: NMRCalcCategory, to value: Double) -> Bool {
        switch category {
        case .resonance:
            return false
            
        case .acquisition:
            guard acqNMR != nil else { return false }
            return acqNMR!.set(parameter: name, to: value)
            
        case .spectrum:
            guard specNMR != nil, let name = NMRSpectrum.Parameter(rawValue: name) else { return false }
            return specNMR!.set(parameter: name, to: value)
            
        case .pulse1:
            guard pulseNMR[0] != nil, let name = NMRPulse.Parameter(rawValue: name) else { return false }
            return pulseNMR[0]!.set(parameter: name, to: value)
            
        case .pulse2:
            guard pulseNMR[1] != nil, let name = NMRPulse.Parameter(rawValue: name) else { return false }
            return pulseNMR[1]!.set(parameter: name, to: value)
            
        case .ernstAngle:
            guard let name = NMRErnstAngle.Parameter(rawValue: name) else { return false }
            return setErnstParameter(name, to: value)
        }
        
    }
    
    func evaluate(parameter name: String, in category: NMRCalcCategory) -> Bool {
        switch category {
        case .resonance:
            return false
            
        case .acquisition:
            guard acqNMR != nil else { return false }
            return acqNMR!.update(parameter: name)
            
        case .spectrum:
            guard specNMR != nil, let name = NMRSpectrum.Parameter(rawValue: name) else { return false }
            return specNMR!.update(parameter: name)
            
        case .pulse1:
            guard pulseNMR[0] != nil else { return false }
            return pulseNMR[0]!.update(parameter: NMRPulse.Parameter(rawValue: name)!)
            
        case .pulse2:
            guard pulseNMR[1] != nil else { return false }
            return pulseNMR[1]!.update(parameter: NMRPulse.Parameter(rawValue: name)!)
            
        case .ernstAngle:
            guard let ernstAngle = NMRErnstAngle.Parameter(rawValue: name) else { return false }
            return evaluateErnstParameter(ernstAngle)
        }
    }
}

// MARK: - Convenience methods
extension NMRCalc {
    func updateParameter(_ name: String, in category: NMRCalcCategory, to value: Double, and name2: String, completionHandler: @escaping (_ error: String?) -> Void) {
        guard setParameter(name, in: category, to: value), evaluate(parameter: name2, in: category) else {
            completionHandler("Cannot update \(name2).")
            return
        }
        
        completionHandler(nil)
    }
    
    func updateLarmor(_ name: String, to value: Double, completionHandler: @escaping (_ error: String?) -> Void) {
        guard let parameter = NMRLarmor.Parameter(rawValue: name) else {
            completionHandler("There is no parameter named (\name).")
            return
        }
        
        guard larmorNMR!.update(parameter, to: value) else {
            completionHandler("The value is out of range.")
            return
        }

    }
}

// MARK:- Methods to access
extension NMRCalc {
    func getLarmor() -> [NMRLarmor.Parameter : Double]? {
        guard let larmor = larmorNMR else {
            return nil
        }
        
        let dict = [NMRLarmor.Parameter.larmor: larmor.frequencyLarmor,
                    NMRLarmor.Parameter.field: larmor.fieldExternal,
                    NMRLarmor.Parameter.proton: larmor.frequencyProton,
                    NMRLarmor.Parameter.electron: larmor.frequencyElectron]
        
        return dict
    }
    
    func getAcq() -> [NMRfid.Parameter : Double]? {
        guard let acqNMR = acqNMR else {
            return nil
        }
        
        let dict = [NMRfid.Parameter.size: Double(acqNMR.size),
                    NMRfid.Parameter.duration: acqNMR.duration,
                    NMRfid.Parameter.dwell: acqNMR.dwell]
        
        return dict
    }
    
    func getSpec() -> [NMRSpectrum.Parameter : Double]? {
        guard let specNMR = specNMR else {
            return nil
        }
        
        let dict = [NMRSpectrum.Parameter.size: Double(specNMR.size),
                    NMRSpectrum.Parameter.width: specNMR.width,
                    NMRSpectrum.Parameter.resolution: specNMR.resolution]
        
        return dict
    }
    
    func getPulse(index: Int) -> [NMRPulse.Parameter : Double]? {
        guard let pulseNMR = pulseNMR[index] else {
            return nil
        }
        
        let dict = [NMRPulse.Parameter.duration: pulseNMR.duration,
                    NMRPulse.Parameter.flipAngle: pulseNMR.flipAngle,
                    NMRPulse.Parameter.amplitude: pulseNMR.amplitude]
        
        return dict
    }
    
    func getErnstAngle() -> [NMRErnstAngle.Parameter : Double]? {
        guard let ernstAngle = ernstAngle else {
            return nil
        }
        
        let dict = [NMRErnstAngle.Parameter.repetition: ernstAngle.repetitionTime,
                    NMRErnstAngle.Parameter.relaxation: ernstAngle.relaxationTime,
                    NMRErnstAngle.Parameter.angleErnst: ernstAngle.angleErnst]
        
        return dict
    }
    
}
