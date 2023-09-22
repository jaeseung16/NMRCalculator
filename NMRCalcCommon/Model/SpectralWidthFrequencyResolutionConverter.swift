//
//  SpectralWidthFrequencyResolutionConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/11/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class SpectralWidthFrequencyResolutionConverter {
    
    public var spectralWidth: Double // Hz
    public var numberOfPoints: Int
    public var frequencyResolution: Double // Hz
    
    public var spectralWidthInkHz: Double {
        return spectralWidth / 1000.0
    }
    
    public init(spectralWidth: Double, frequencyResolution: Double) {
        self.spectralWidth = spectralWidth
        self.frequencyResolution = frequencyResolution
        self.numberOfPoints = Int(spectralWidth / frequencyResolution)
    }
    
    public init(spectralWidth: Double, numberOfPoints: Int) {
        self.spectralWidth = spectralWidth
        self.numberOfPoints = numberOfPoints
        self.frequencyResolution = spectralWidth / Double(numberOfPoints)
    }
    
    public init(frequencyResolution: Double, numberOfPoints: Int) {
        self.frequencyResolution = frequencyResolution
        self.numberOfPoints = numberOfPoints
        self.spectralWidth = Double(numberOfPoints) * frequencyResolution
    }
    
    private func updateNumberOfPoints() {
        numberOfPoints = Int(spectralWidth / frequencyResolution)
    }
    
    private func updateFrequencyResolution() {
        frequencyResolution = spectralWidth / Double(numberOfPoints)
    }
    
    private func updateSpectralWidth() {
        spectralWidth = Double(numberOfPoints) * frequencyResolution
    }

    public func set(spectralWidth: Double) -> Void {
        self.spectralWidth = spectralWidth
        updateFrequencyResolution()
    }
    
    public func set(spectralWidthInkHz: Double) -> Void {
        self.spectralWidth = spectralWidthInkHz * 1000
        updateFrequencyResolution()
    }
    
    public func set(frequencyResolution: Double) -> Void {
        self.frequencyResolution = frequencyResolution
        updateNumberOfPoints()
    }
    
    public func set(numberOfPoints: Int) -> Void {
        self.numberOfPoints = numberOfPoints
        updateFrequencyResolution()
    }
}
