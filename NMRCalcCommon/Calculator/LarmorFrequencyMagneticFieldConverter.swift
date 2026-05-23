//
//  FrequencyFieldConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/11/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

public class LarmorFrequencyMagneticFieldConverter {
    private static let γProton = NMRCalcConstants.gammaProton
    private static let γElectron = NMRCalcConstants.gammaElectron
    
    public var larmorFrequency: Double // Hz
    public var magneticField: Double // Tesla
    public var gyromagneticRatio: Double // Hz/Tesla
    
    public var electroFrequency: Double {
        return magneticField * LarmorFrequencyMagneticFieldConverter.γElectron
    }
    
    public var protonFrequency: Double {
        return magneticField * LarmorFrequencyMagneticFieldConverter.γProton
    }
    
    public init(larmorFrequency: Double, magneticField: Double) {
        self.larmorFrequency = larmorFrequency
        self.magneticField = magneticField
        self.gyromagneticRatio = larmorFrequency / magneticField
    }
    
    public init(magneticField: Double, gyromagneticRatio: Double) {
        self.magneticField = magneticField
        self.gyromagneticRatio = gyromagneticRatio
        self.larmorFrequency = gyromagneticRatio * magneticField
    }
    
    public init(larmorFrequency: Double, gyromagneticRatio: Double) {
        self.larmorFrequency = larmorFrequency
        self.gyromagneticRatio = gyromagneticRatio
        self.magneticField = larmorFrequency / gyromagneticRatio
    }
    
    private func updateMagneticField() {
        magneticField = larmorFrequency / gyromagneticRatio
    }
    
    private func updateLarmorFrequency() {
        larmorFrequency = gyromagneticRatio * magneticField
    }
    
    private func updateGyromagneticRatio() {
        gyromagneticRatio = larmorFrequency / magneticField
    }

    public func set(larmorFrequency: Double) -> Void {
        self.larmorFrequency = larmorFrequency
        updateMagneticField()
    }
    
    public func set(electronFrequency: Double) -> Void {
        set(magneticField: electronFrequency / LarmorFrequencyMagneticFieldConverter.γElectron)
    }
    
    public func set(protonFrequency: Double) -> Void {
        set(magneticField: protonFrequency / LarmorFrequencyMagneticFieldConverter.γProton)
    }
    
    public func set(magneticField: Double) -> Void {
        self.magneticField = magneticField
        updateLarmorFrequency()
    }
    
    public func set(gyromagneticRatio: Double) -> Void {
        self.gyromagneticRatio = gyromagneticRatio
        updateLarmorFrequency()
    }
    
}
