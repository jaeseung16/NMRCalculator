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
    private let ernstAngleCalculator: ErnstAngleCalculator
    
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
        
        self.ernstAngleCalculator = ErnstAngleCalculator(repetitionTime: 1.0, relaxationTime: 1.0)
        commands[.ernstAngle] = UpdateErnstAngle(ernstAngleCalculator)
        commands[.repetitionTime] = UpdateRepetitionTime(ernstAngleCalculator)
        commands[.relaxationTime] = UpdateRelaxationTime(ernstAngleCalculator)
    }
    
    // MARK: - Validation
    
    func isPositive(_ value: Double) -> Bool {
        return value > 0.0
    }
    
    func isNonNegative(_ value: Double) -> Bool {
        return value >= 0.0
    }
    
    func validate(externalField B0: Double) -> Bool {
        return abs(B0) <= 1000.0
    }
    
    func validate(numberOfDataPoints: Double) -> Bool {
        return numberOfDataPoints >= 1.0
    }
    
    func validate(ernstAngle: Double) -> Bool {
        return ernstAngle > 0.0 && ernstAngle < 90.0
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
    
    // MARK: - Ernst Angle
    @Published var ernstAngleUpdated = false
    
    var repetitionTime: Double {
        ernstAngleCalculator.repetitionTime
    }
    
    var relaxationTime: Double {
        ernstAngleCalculator.relaxationTime
    }
    
    var ernstAngle: Double {
        ernstAngleCalculator.ernstAngle
    }
}
