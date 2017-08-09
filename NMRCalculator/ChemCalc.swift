//
//  ChemCalc.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 7/12/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import Foundation

class ChemCalc {
    let mw_h2o: Double = 18.0
    var molecularweight: Double?
    var molL: Double? // mol/L
    var massfraction: Double? // mass fraction
    var mol: Double? // solute amount in mol
    var weight: Double? // solute amount in gram
    var amount_h2o: Double? // solvent amount in gram or mL
    var chemicalName: String?
    
    init() {

    }
    
    // MARK: Method to set parameter
    
    enum chemCategory: String {
        case chemical
        case molecularWeight
        case amountSolute
        case amountSolvent
    }
    
    func setParameter(_ name: String, in category: String, to value: String) -> Bool {
        guard let category = chemCategory(rawValue: category) else { return false }
        
        switch category {
        case .chemical:
            self.chemicalName = value
        default:
            break
        }
        return false
        
    }
    
    // MARK: set the name of a chemical
    
    func set_chemicalname(_ name: String) {
        chemicalName = name
    }
    
    // MARK: set the molecular weight of a chemical
    
    func set_molecularweight(_ mw: Double) -> Bool {
        if mw > 0 {
            molecularweight = mw
            return true
        }
        
        return false
    }
    
    // MARK: set the amount of solute or solvent
    
    enum amount: String {
        case solute
        case solvent
    }
    
    func set_amount(_ of: String, gram: Double) -> Bool {
        if let to_set = amount(rawValue: of) {
            if gram > 0 {
                switch to_set {
                case .solute:
                    weight = gram
                case .solvent:
                    amount_h2o = gram
                }
                return true
            }
        }
        
        return false
    }
    
    func set_amount(_ mol: Double) -> Bool {
        if mol > 0 {
            self.mol = mol
            return true
        }
        
        return false
    }
    
    // MARK: set concentrations in mol/L or mass fraction
    
    enum concentration: String {
        case molL
        case mass
    }
    
    func set_concentration(_ kind: String, number: Double) -> Bool {
        if let to_set = concentration(rawValue: kind) {
            if number > 0 {
                switch to_set {
                case .molL:
                    molL = number
                case .mass:
                    massfraction = number
                }
                return true
            }
        }
        return false
    }
    
    // MARK: Methods to update paramters
    
    enum willUpdate: String {
        case mol
        case mol_reverse
        case weight
        case weight_reverse
        case molL
        case mass
    }
    
    func update(_ name: String) -> Bool {
        if let to_update = willUpdate(rawValue: name) {
            switch to_update {
            case .mol:
                if weight != nil && molecularweight != nil {
                    mol = weight! / molecularweight!
                    return true
                }
            case .mol_reverse:
                if molL != nil && amount_h2o != nil {
                    mol = molL! * (amount_h2o! / 1000.0)
                    return true
                }
            case .weight:
                if mol != nil && molecularweight != nil {
                    weight = mol! * molecularweight!
                    return true
                }
            case .weight_reverse:
                if massfraction != nil && amount_h2o != nil {
                    weight = amount_h2o! * massfraction! / (1 - massfraction!)
                    return true
                }
            case .molL:
                if mol != nil && amount_h2o != nil {
                    molL = mol! / (amount_h2o! / 1000.0)
                    return true
                }
            case .mass:
                if weight != nil && amount_h2o != nil {
                    massfraction = weight! / (weight! + amount_h2o!)
                    return true
                }
            }
        }
        
        return false
    }

}
