//
//  ErnstAngleConverter.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 5/26/26.
//  Copyright © 2026 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

class ErnstAngleConverter {
    private static let logger = Logger()
    
    private static let radianToDegree = 180.0 / Double.pi
    private static var degreeToRadian = Double.pi / 180.0
    
    public var ernstAngle: Double // degree
    public var repetitionTime: Double // sec
    public var relaxationTime: Double // sec
    
    private let delegate: NMRCalcDelegate
    private var error: NMRCalcError?
    
    private static func ernstAngle(repetitionTime: Double, relaxationTime: Double) -> Double {
        return acos( exp(-1.0 * repetitionTime / relaxationTime) ) * radianToDegree
    }
    
    public init(ernstAngle: Double, repetitionTime: Double, relaxationTime: Double) {
        self.ernstAngle = ernstAngle
        self.repetitionTime = repetitionTime
        self.relaxationTime = relaxationTime
        self.delegate = NMRCalcFactory.shared.create(.ernst)
    }
    
    public convenience init(repetitionTime: Double, relaxationTime: Double) {
        self.init(ernstAngle: Self.ernstAngle(repetitionTime: repetitionTime, relaxationTime: relaxationTime),
                  repetitionTime: repetitionTime,
                  relaxationTime: relaxationTime)
    }
    
    private func update(from response: ErnstAngleResponse) {
        self.ernstAngle = response.ernstAngleInDegree
        self.repetitionTime = response.repetitionTimeInSec
        self.relaxationTime = response.relaxationTimeInSec
    }
    
    private func process(_ request: NMRCalcRequest) {
        let result = delegate.process(request)
        switch result {
        case .success(let response):
            guard let response = response as? ErnstAngleResponse else {
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
    
    public func set(repetitionTime: Double) {
        let request = ErnstAngleRequest(repetitionTimeInSec: repetitionTime, relaxationTimeInSec: relaxationTime)
        process(request)
    }
    
    public func set(relaxationTime: Double) {
        let request = ErnstAngleRequest(repetitionTimeInSec: repetitionTime, relaxationTimeInSec: relaxationTime)
        process(request)
    }
    
    public func set(ernstAngle: Double) {
        let request = ErnstAngleRequest(ernstAngleInDegree: ernstAngle, relaxationTimeInSec: relaxationTime)
        process(request)
    }
    
}
