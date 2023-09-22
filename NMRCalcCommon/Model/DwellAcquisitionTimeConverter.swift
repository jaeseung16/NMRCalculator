//
//  DwellAcquisitionTimeConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/13/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class DwellAcquisitionTimeConverter {
    private static let secToμs: Double = 1000000.0
    private static var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    public var acqusitionTime: Double // sec
    public var numberOfPoints: Int //
    public var dwell: Double // sec
    
    public var dwellInμs: Double {
        return dwell * DwellAcquisitionTimeConverter.secToμs
    }
    
    public init(acqusitionTime: Double, dwell: Double) {
        self.acqusitionTime = acqusitionTime
        self.dwell = dwell
        self.numberOfPoints = Int(acqusitionTime / dwell)
    }
    
    public init(acqusitionTime: Double, numberOfPoints: Int) {
        self.acqusitionTime = acqusitionTime
        self.numberOfPoints = numberOfPoints
        self.dwell = acqusitionTime / Double(numberOfPoints)
    }
    
    public init(dwell: Double, numberOfPoints: Int) {
        self.dwell = dwell
        self.numberOfPoints = numberOfPoints
        self.acqusitionTime = Double(numberOfPoints) * dwell
    }
    
    private func updateNumberOfPoints() {
        numberOfPoints = Int(acqusitionTime / dwell)
    }
    
    private func updateDwell() {
        dwell = acqusitionTime / Double(numberOfPoints)
    }
    
    private func updateAcquisitionTime() {
        acqusitionTime = Double(numberOfPoints) * dwell
    }

    public func set(acqusitionTime: Double) -> Void {
        self.acqusitionTime = acqusitionTime
        updateDwell()
    }
    
    public func set(dwell: Double) -> Void {
        self.dwell = dwell
        updateAcquisitionTime()
    }
    
    public func set(dwellInμs: Double) -> Void {
        self.dwell = dwellInμs * DwellAcquisitionTimeConverter.μsToSec
        updateAcquisitionTime()
    }
    
    public func set(numberOfPoints: Int) -> Void {
        self.numberOfPoints = numberOfPoints
        updateDwell()
    }
}
