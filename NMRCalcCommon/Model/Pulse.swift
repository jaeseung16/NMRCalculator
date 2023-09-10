//
//  PulseParameterConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/13/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class Pulse {
    private static let radianToDegree = 180.0 / Double.pi
    private static var degreeToRadian: Double {
        return 1.0 / radianToDegree
    }
    
    private static let secToμs: Double = 1000000.0
    private static var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    public var duration: Double // μs
    public var flipAngle: Double // degree
    public var amplitude: Double // Hz
    
    public var durationInSec: Double {
        duration * Pulse.μsToSec
    }
    
    public var flipAnlgeInRotation: Double {
        flipAngle / 360.0
    }
    
    public var flipAngleInRadian: Double {
        flipAngle * Pulse.degreeToRadian
    }
    
    public var amplitudeInMHz: Double {
        amplitude / 1000000.0
    }
    
    public init(duration: Double, flipAngle: Double) {
        self.duration = duration
        self.flipAngle = flipAngle
        self.amplitude = (flipAngle/360.0) / (duration * Pulse.μsToSec)
    }
    
    public init(duration: Double, amplitude: Double) {
        self.duration = duration
        self.amplitude = amplitude
        self.flipAngle = amplitude * (duration * Pulse.μsToSec) * 360.0
    }
    
    public init(flipAngle: Double, amplitude: Double) {
        self.flipAngle = flipAngle
        self.amplitude = amplitude
        self.duration = (flipAngle/360.0) / amplitude * Pulse.secToμs
    }
    
    private func updateDuration() {
        self.duration = flipAnlgeInRotation / amplitudeInMHz
    }
    
    private func updateFlipAngle() {
        self.flipAngle = amplitudeInMHz * duration * 360.0
    }
    
    private func updateAmplitude() {
        self.amplitude = flipAnlgeInRotation / durationInSec
        print("\(amplitude)")
    }

    public func set(duration: Double) -> Void {
        self.duration = duration
        updateAmplitude()
    }
    
    public func set(flipAngle: Double) -> Void {
        self.flipAngle = flipAngle
        updateAmplitude()
    }
    
    public func set(amplitude: Double) -> Void {
        self.amplitude = amplitude
        updateDuration()
    }
}
