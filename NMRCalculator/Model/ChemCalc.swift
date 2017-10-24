//
//  ChemCalc.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/12/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class ChemCalc {
    let mwH2O: Double = 18.0
    var molecularWeight: Double = 100.0
    var molConcentration: Double // mol/L
    var wtConcentration: Double // mass fraction
    var molSolute: Double // solute amount in mol
    var gramSolute: Double = 1.0 // solute amount in gram
    var amountSolvent: Double = 100.0 // solvent amount in gram or mL
    var chemicalName = "Chemical Name (optional)"
    
    init() {
        molSolute = gramSolute / molecularWeight
        molConcentration = molSolute / (amountSolvent / 1000.0)
        wtConcentration = gramSolute / (gramSolute + amountSolvent)
    }
    
    // MARK: Method to set parameter
    
    enum chemCategory: String {
        case chemical
        case molecularWeight
        case molConcentration
        case wtConcentration
        case molSolute
        case gramSolute
        case amountSolvent
    }
    
    func setParameter(_ name: String, to value: String) -> Bool {
        guard let category = chemCategory(rawValue: name) else { return false }
        
        switch category {
        case .chemical:
            self.chemicalName = value
        default:
            return false
        }
        
        return true
    }
    
    func setParameter(_ name: String, to value: Double) -> Bool {
        guard let category = chemCategory(rawValue: name) else { return false }
        
        if value > 0 {
            switch category {
            case .molecularWeight:
                self.molecularWeight = value
            case .molConcentration:
                self.molConcentration = value
            case .wtConcentration:
                self.wtConcentration = value
            case .molSolute:
                self.molSolute = value
            case .gramSolute:
                self.gramSolute = value
            case .amountSolvent:
                self.amountSolvent = value
            default:
                return false
            }
            return true
        } else {
            return false
        }
        
    }
    
    func updateParameter(_ name: String, flag: Bool = true) -> Bool {
        guard let category = chemCategory(rawValue: name) else { return false }
        
        switch category {
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
    
}
