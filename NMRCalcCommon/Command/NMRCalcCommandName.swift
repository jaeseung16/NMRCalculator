//
//  NMRCalcCommandName.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/10/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

enum NMRCalcCommandName: String {
    case magneticField
    case larmorFrequency
    case protonFrequency
    case electronFrequency
    
    case acquisitionTime
    case dwellTime
    case dwellTimeInμs
    case acquisitionSize
    
    case spectrumSize
    case frequencyResolution
    case spectralWidth
    case spectralWidthInkHz
    
    case pulse1Duration
    case pulse2Duration
    case pulse1FlipAngle
    case pulse2FlipAngle
    case pulse1Amplitude
    case pulse1AmplitudeInT
    case pulse2Amplitude
    
    case ernstAngle
    case repetitionTime
    case relaxationTime
}
