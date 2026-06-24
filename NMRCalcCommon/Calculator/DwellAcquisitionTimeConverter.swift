//
//  DwellAcquisitionTimeConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/13/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

class DwellAcquisitionTimeConverter {
    private static let logger = Logger()
    
    private static let secToμs: Double = 1000000.0
    private static var μsToSec: Double {
        get {
            return 1.0 / secToμs
        }
    }
    
    public var acqusitionTime: Double // sec
    public var numberOfPoints: Int //
    public var dwell: Double // sec
    
    private let delegate: NMRCalcDelegate
    private var error: NMRCalcError?
    
    public var dwellInμs: Double {
        return dwell * Self.secToμs
    }
    
    public init(acqusitionTime: Double, numberOfPoints: Int, dwell: Double) {
        self.acqusitionTime = acqusitionTime
        self.numberOfPoints = numberOfPoints
        self.dwell = dwell
        self.delegate = NMRCalcFactory.shared.create(.time)
    }
    
    public convenience init(acqusitionTime: Double, dwell: Double) {
        self.init(acqusitionTime: acqusitionTime,
                  numberOfPoints: Int(acqusitionTime / dwell),
                  dwell: dwell)
    }
    
    public convenience init(acqusitionTime: Double, numberOfPoints: Int) {
        self.init(acqusitionTime: acqusitionTime,
                  numberOfPoints: numberOfPoints,
                  dwell: acqusitionTime / Double(numberOfPoints))
    }
    
    public convenience init(dwell: Double, numberOfPoints: Int) {
        self.init(acqusitionTime: Double(numberOfPoints) * dwell,
                  numberOfPoints: numberOfPoints,
                  dwell: dwell)
    }
    
    private func update(from response: TimeDomainResponse) {
        self.acqusitionTime = response.acqusitionTimeInSec
        self.numberOfPoints = response.numberOfPoints
        self.dwell = response.dwellInSec
    }
    
    private func process(_ request: NMRCalcRequest) {
        let result = delegate.process(request)
        switch result {
        case .success(let response):
            guard let response = response as? TimeDomainResponse else {
                Self.logger.error("Invalid response type: \(type(of: response))")
                error = .invalidOutput
                break
            }
            update(from: response)
        case .failure(let error):
            Self.logger.error("Failed to process: \(String(describing: request))")
            self.error = error
        }
    }

    public func set(acqusitionTime: Double) -> Void {
        let request = TimeDomainRequest(acqusitionTimeInSec: acqusitionTime, numberOfPoints: numberOfPoints)
        process(request)
    }
    
    public func set(dwell: Double) -> Void {
        let request = TimeDomainRequest(numberOfPoints: numberOfPoints, dwellInSec: dwell)
        process(request)
    }
    
    public func set(dwellInμs: Double) -> Void {
        let request = TimeDomainRequest(numberOfPoints: numberOfPoints, dwellInSec: dwellInμs * Self.μsToSec)
        process(request)
    }
    
    public func set(numberOfPoints: Int) -> Void {
        let request = TimeDomainRequest(acqusitionTimeInSec: acqusitionTime, numberOfPoints: numberOfPoints)
        process(request)
    }
}
