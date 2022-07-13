//
//  FrequencyFieldConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/11/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

public class LarmorFrequencyMagneticFieldConverter {
    
    public var larmorFrequency: Double // Hz
    public var magneticField: Double // Tesla
    public var gyromagneticRatio: Double // Hz/Tesla
    
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
    
    private func setMagneticField() {
        magneticField = larmorFrequency / gyromagneticRatio
    }
    
    private func setLarmorFrequency() {
        larmorFrequency = gyromagneticRatio * magneticField
    }
    
    private func setGyromagneticRatio() {
        gyromagneticRatio = larmorFrequency / magneticField
    }

    public func update(larmorFrequency: Double) -> Void {
        self.larmorFrequency = larmorFrequency
        setMagneticField()
    }
    
    public func update(magneticField: Double) -> Void {
        self.magneticField = magneticField
        setLarmorFrequency()
    }
    
    public func update(gyromagneticRatio: Double) -> Void {
        self.gyromagneticRatio = gyromagneticRatio
        setLarmorFrequency()
    }
    
}
