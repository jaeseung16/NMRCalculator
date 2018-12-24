//
//  ChemCalc.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/12/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class ChemCalc {
    // MARK: Properties
    let mwH2O: Double = 18.0
    var molecularWeight: Double = 100.0
    var molConcentration: Double // mol/L
    var wtConcentration: Double // mass fraction
    var molSolute: Double // solute amount in mol
    var gramSolute: Double = 1.0 // solute amount in gram
    var amountSolvent: Double = 100.0 // solvent amount in gram or mL
    var chemicalName = "Chemical Name (optional)"
    
    // MARK: - enum
    enum Category: String {
        case chemical
        case molecularWeight
        case molConcentration
        case wtConcentration
        case molSolute
        case gramSolute
        case amountSolvent
    }
    
    // MARK: - Methods
    init() {
        molSolute = gramSolute / molecularWeight
        molConcentration = molSolute / (amountSolvent / 1000.0)
        wtConcentration = gramSolute / (gramSolute + amountSolvent)
    }

    // MARK: - Methods to set parameter
    func set(parameter name: Category, to value: String) -> Bool {
        switch name {
        case .chemical:
            self.chemicalName = value
        default:
            return false
        }
        
        return true
    }
    
    func set(parameter name: Category, to value: Double) -> Bool {
        guard value > 0 else { return false }
        
        switch name {
        case .chemical:
            return false
        case .molecularWeight:
            molecularWeight = value
        case .molConcentration:
            molConcentration = value
        case .wtConcentration:
            wtConcentration = value
        case .molSolute:
            molSolute = value
        case .gramSolute:
            gramSolute = value
        case .amountSolvent:
            amountSolvent = value
        }
        return true
    }
    
    // MARK: - Methods to update parameters
    func update(parameter name: Category, flag: Bool = true) -> Bool {
        switch name {
        case .molSolute:
            if flag {
                molSolute = gramSolute / molecularWeight
            } else {
                molSolute = molConcentration * (amountSolvent / 1000.0)
            }
        case .gramSolute:
            if flag {
                gramSolute = molSolute * molecularWeight
            } else {
                gramSolute = amountSolvent * wtConcentration / ( 1 - wtConcentration )
            }
        case .molConcentration:
            molConcentration = molSolute / (amountSolvent / 1000.0)
        case .wtConcentration:
            wtConcentration = gramSolute / (gramSolute + amountSolvent)
        default:
            return false
        }
        
        return true
    }
    
    // MARK: - Convenience Methods
    func updateMolecularWeight(to value: Double, completionHandler: ((_ error: String?) -> Void) ) {
        guard set(parameter: .molecularWeight, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        guard update(parameter: .molSolute) else {
            completionHandler("Cannot calculate the amount in mol.")
            return
        }
        
        guard update(parameter: .molConcentration) else {
            completionHandler("Cannot calculate the concentration in mM.")
            return
        }
        
        completionHandler(nil)
        return
    }
    
    func updateMolConcentration(to value: Double, completionHandler: ((_ error: String?) -> Void)) {
        guard set(parameter: .molConcentration, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        guard update(parameter: .molSolute, flag: false) else {
            completionHandler("Cannot calculate the amount in mol.")
            return
        }
        
        guard update(parameter: .gramSolute) else {
            completionHandler("Cannot calculate the amount in mg.")
            return
        }
        
        guard update(parameter: .wtConcentration) else {
            completionHandler("Cannot calculate the concentration in wt%.")
            return
        }
        
        completionHandler(nil)
        return
    }
    
    func updateWtConcentration(to value: Double, completionHandler: ((_ error: String?) -> Void)) {
        guard set(parameter: .wtConcentration, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        guard update(parameter: .gramSolute, flag: false) else {
            completionHandler("Cannot calculate the amount in mg.")
            return
        }
        
        guard update(parameter: .molSolute) else {
            completionHandler("Cannot calculate the amount in mol.")
            return
        }
        
        guard update(parameter: .molConcentration) else {
            completionHandler("Cannot calculate the concentration in mM.")
            return
        }
        
        completionHandler(nil)
        return
    }
    
    func updateGramSolute(to value: Double, completionHandler: ((_ error: String?) -> Void)) {
        guard set(parameter: .gramSolute, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        guard update(parameter: .molSolute) else {
            completionHandler("Cannot calculate the amount in mol.")
            return
        }
        
        guard update(parameter: .molConcentration) else {
            completionHandler("Cannot calculate the concentration in mM.")
            return
        }
        
        guard update(parameter: .wtConcentration) else {
            completionHandler("Cannot calculate the concentration in wt%.")
            return
        }
        
        completionHandler(nil)
        return
    }
    
    func updateAmountSolvent(to value: Double, completionHandler: ((_ error: String?) -> Void)) {
        guard set(parameter: .amountSolvent, to: value) else {
            completionHandler("The value is out of range.")
            return
        }
        
        guard update(parameter: .molConcentration) else {
            completionHandler("Cannot calculate the concentration in mM.")
            return
        }
        
        guard update(parameter: .wtConcentration) else {
            completionHandler("Cannot calculate the concentration in wt%.")
            return
        }
        
        completionHandler(nil)
        return
    }
}
