//
//  MacNMRSignalCalculator.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/25/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import Foundation

class MacNMRSignalCalculator: ObservableObject, CustomStringConvertible {
    @Published var numberOfTimeDataPoint: Double?
    @Published var acquisitionDuration: Double?
    @Published var dwellTime: Double?
    @Published var numberOfFrequencyDataPoint: Double?
    @Published var spectralWidth: Double?
    @Published var frequencyResolution: Double?
    
    private let msToμs: Double = 1000.0
    private var μsToMs: Double {
        get {
            return 1.0 / msToμs
        }
    }
    
    var description: String {
        return "numberOfTimeDataPoint = \(numberOfTimeDataPoint), acquisitionDuration = \(acquisitionDuration), dwellTime = \(dwellTime)"
    }
    
    func numberOfTimeDataPointUpdated() {
        if acquisitionDuration == nil {
            acquisitionDuration = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1000.0
        }
        
        dwellTime = acquisitionDuration! * 1000000 / numberOfTimeDataPoint!
    }
    
    func acquisitionDurationUpdated() {
        if acquisitionDuration == nil {
            acquisitionDuration = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1000.0
        }
        
        dwellTime = acquisitionDuration! * 1000000 / numberOfTimeDataPoint!
    }
    
    func dwellTimeUpdated() {
        if dwellTime == nil {
            dwellTime = 1.0
        }
        
        if numberOfTimeDataPoint == nil {
            numberOfTimeDataPoint = 1.0
        }
        
        acquisitionDuration = numberOfTimeDataPoint! * (dwellTime! * 0.000001)
    }
    
    func numberOfFrequencyDataPointUpdated() {
        if numberOfFrequencyDataPoint == nil {
            numberOfFrequencyDataPoint = 1000.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        frequencyResolution = 1000.0 * spectralWidth! / numberOfFrequencyDataPoint!
    }
    
    func spectralWidthUpdated() {
        if numberOfFrequencyDataPoint == nil {
            numberOfFrequencyDataPoint = 1000.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        frequencyResolution = 1000.0 * spectralWidth! / numberOfFrequencyDataPoint!
    }
    
    func frequencyResolutionUpdated() {
        if frequencyResolution == nil {
            frequencyResolution = 1.0
        }
        
        if spectralWidth == nil {
            spectralWidth = 1.0
        }
        
        numberOfFrequencyDataPoint = 1000.0 * spectralWidth! / frequencyResolution!
    }
}
