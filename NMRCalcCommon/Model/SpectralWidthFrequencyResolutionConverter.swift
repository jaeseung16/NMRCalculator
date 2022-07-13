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
    
    private func setNumberOfPoints() {
        numberOfPoints = Int(spectralWidth / frequencyResolution)
    }
    
    private func setFrequencyResolution() {
        frequencyResolution = spectralWidth / Double(numberOfPoints)
    }
    
    private func setSpectralWidth() {
        spectralWidth = Double(numberOfPoints) * frequencyResolution
    }

    public func update(spectralWidth: Double) -> Void {
        self.spectralWidth = spectralWidth
        setFrequencyResolution()
    }
    
    public func update(frequencyResolution: Double) -> Void {
        self.frequencyResolution = frequencyResolution
        setSpectralWidth()
    }
    
    public func update(numberOfPoints: Int) -> Void {
        self.numberOfPoints = numberOfPoints
        setFrequencyResolution()
    }
}
