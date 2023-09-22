//
//  NMRCalcConstants.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 2/3/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct NMRCalcConstants {
    static let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    static let gammaElectron = -176.0859644 / 2 / Double.pi // in GHz/T
    
    static let nuclearSpin = "Nuclear Spin"
    static let naturalAbundance = "NA"
    
    enum Title: String {
        case nuclearSpin = "Nuclear Spin"
        case gyromagneticRatio = "Gyromagnetic Ratio (MHz/T)"
        case naturalAbundance = "Natural Abundance (%)"
        case externalField = "External Field"
        case larmorFrequency = "Larmor Frequency"
        case protonFrequency = "Proton Frequency"
        case electronFrequency = "Electron Frequency"
        
        case numberOfDataPoints = "Number of Data Points"
        case acquisitionDuration = "Acquisition Duration"
        case dwellTime = "Dwell Time"
        case spectralWidth = "Spectral Width"
        case frequencyResolution = "Frequency Resolution"
        case pulseDuration = "Pulse Duration"
        case flipAngle = "Flip Angle"
        case rfAmplitude = "RF Amplitude"
        case rfAmplitudeInμT = "RF Amplitude in μT"
        case rfPowerRelativeToPulse1 = "RF Power Relative to Pulse 1"
        case repetitionTime = "Repetition Time"
        case relaxationTime = "Relaxation Time"
        case ernstAngle = "Ernst Angle"
    }
}
