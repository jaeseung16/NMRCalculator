//
//  ToolResponseEvaluator.swift
//  NMRCalculator2
//

import Foundation
import NMRCalculatorCommon
import os

/// Deterministic round-trip verification of calculator responses.
/// The calculated value is fed back into the calculator to solve for one of
/// the given parameters; the result must reproduce the given value within a
/// relative tolerance.
struct ToolResponseEvaluator {
    private static let logger = Logger()
    private static let relativeTolerance = 1.0e-6

    enum ErnstAngleParameter: String {
        case ernstAngle = "Ernst angle"
        case repetitionTime = "repetition time"
        case relaxationTime = "T1 relaxation time"
    }

    static func verify(_ response: ErnstAngleResponse, calculated: ErnstAngleParameter) -> Bool {
        let request: ErnstAngleRequest
        let expected: Double
        let roundTrip: (ErnstAngleResponse) -> Double
        switch calculated {
        case .ernstAngle:
            // Solve for the repetition time from the calculated angle and the given T1.
            request = ErnstAngleRequest(ernstAngleInDegree: response.ernstAngleInDegree,
                                        relaxationTimeInSec: response.relaxationTimeInSec)
            expected = response.repetitionTimeInSec
            roundTrip = { $0.repetitionTimeInSec }
        case .repetitionTime, .relaxationTime:
            // Solve for the angle from the times; one of them is the calculated value.
            request = ErnstAngleRequest(repetitionTimeInSec: response.repetitionTimeInSec,
                                        relaxationTimeInSec: response.relaxationTimeInSec)
            expected = response.ernstAngleInDegree
            roundTrip = { $0.ernstAngleInDegree }
        }
        guard case .success(let result) = NMRCalcFactory.shared.create(.ernst).process(request),
              let result = result as? ErnstAngleResponse else {
            Self.logger.error("Round-trip request failed for \(String(describing: response))")
            return false
        }
        return isClose(roundTrip(result), to: expected)
    }

    private static func isClose(_ value: Double, to expected: Double) -> Bool {
        guard value.isFinite, expected.isFinite else { return false }
        return abs(value - expected) <= relativeTolerance * max(abs(value), abs(expected), 1.0)
    }
}
