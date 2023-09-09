//
//  NMRCalc2ViewModel.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os

class NMRCalculator2: ObservableObject {
    private let logger = Logger()
    
    private let periodicTable = NMRPeriodicTableData()
    
    private let nucleus: NMRNucleus
    
    private let larmorFrequencyCalculator: LarmorFrequencyMagneticFieldConverter
    
    private var commands: [NMRCalcCommandName: NMRCalcCommand]
    
    @Published var updated = false
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
        self.larmorFrequencyCalculator = LarmorFrequencyMagneticFieldConverter(magneticField: 1.0, gyromagneticRatio: nucleus.γ)
        
        commands = [NMRCalcCommandName: NMRCalcCommand]()
        commands[.larmorFrequency] = UpdateLarmorFrequency(larmorFrequencyCalculator)
        commands[.magneticField] = UpdateMagneticField(larmorFrequencyCalculator)
        commands[.protonFrequency] = UpdateProtonFrequency(larmorFrequencyCalculator)
        commands[.electronFrequency] = UpdateElectronFrequency(larmorFrequencyCalculator)
    }
    
    func validate(externalField B0: Double) -> Bool {
        return abs(B0) <= 1000.0
    }
    
    
    func update(_ commandName: NMRCalcCommandName, to value: Double) -> Void {
        if let command = commands[commandName] {
            command.execute(with: value)
            updated.toggle()
        } else {
            logger.log("Can't find any command named \(commandName.rawValue, privacy: .public)")
        }
    }
    
    // MARK: - Larmor frequency
    var γNucleus: Double {
        guard let γNucleus = Double(nucleus.gyromagneticRatio) else {
            return NMRCalcConstants.gammaProton
        }
        return γNucleus
    }
    
    var externalField: Double {
        larmorFrequencyCalculator.magneticField
    }
    
    var larmorFrequency: Double {
        larmorFrequencyCalculator.larmorFrequency
    }
    
    var protonFrequency: Double {
        larmorFrequencyCalculator.protonFrequency
    }
    
    var electronFrequency: Double {
        larmorFrequencyCalculator.electroFrequency
    }
}
