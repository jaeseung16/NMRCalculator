//
//  MacNMRSignalCalculator.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Foundation

class SignalCalculatorViewModel: ObservableObject {
    @Published var numberOfTimeDataPoint: Double?
    @Published var acquisitionDuration: Double?
    @Published var dwellTime: Double?
    @Published var numberOfFrequencyDataPoint: Double?
    @Published var spectralWidth: Double?
    @Published var frequencyResolution: Double?
    
    private let secToμs: Double = 1000000.0
    private var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    private let kHzToHz: Double = 1000.0
    
    private func updateDwellTime() {
        dwellTime = acquisitionDuration! * secToμs / numberOfTimeDataPoint!
    }
    
    func numberOfTimeDataPointUpdated() {
        if acquisitionDuration == nil {
            acquisitionDuration = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1000.0
        }
        
        updateDwellTime()
    }
    
    func acquisitionDurationUpdated() {
        if acquisitionDuration == nil {
            acquisitionDuration = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1000.0
        }
        
        updateDwellTime()
    }
    
    func dwellTimeUpdated() {
        if dwellTime == nil {
            dwellTime = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1.0
        }
        
        acquisitionDuration = numberOfTimeDataPoint! * (dwellTime! * μsToSec)
    }
    
    private func updateFrequencyResolution() {
        frequencyResolution =  spectralWidth! * kHzToHz / numberOfFrequencyDataPoint!
    }
    
    func numberOfFrequencyDataPointUpdated() {
        if numberOfFrequencyDataPoint == nil {
            numberOfFrequencyDataPoint = 1000.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        updateFrequencyResolution()
    }
    
    func spectralWidthUpdated() {
        if numberOfFrequencyDataPoint == nil {
            numberOfFrequencyDataPoint = 1000.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        updateFrequencyResolution()
    }
    
    func frequencyResolutionUpdated() {
        if frequencyResolution == nil {
            frequencyResolution = 1.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        numberOfFrequencyDataPoint = spectralWidth! * kHzToHz / frequencyResolution!
    }
}
