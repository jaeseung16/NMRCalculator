//
//  ErnstAngleTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

struct ErnstAngleTool: Tool {
    private static let logger = Logger()
    
    let name = "calculate_ernst_angle"
    let description = "Calculates Ernst angle or repetition time. Provide T1 relaxation time and one of: repetition time or Ernst angle."

    @Generable
    struct Arguments {
        @Guide(description: "T1 relaxation time in seconds")
        var relaxationTimeT1InSec: Double
        @Guide(description: "Repetition time in seconds; omit to calculate it")
        var repetitionTimeInSec: Double?
        @Guide(description: "Ernst angle in degrees; omit to calculate it")
        var ernstAngleInDegree: Double?
    }

    func call(arguments: Arguments) async throws -> String {
        let request = ErnstAngleRequest(
            ernstAngleInDegree: arguments.ernstAngleInDegree,
            repetitionTimeInSec: arguments.repetitionTimeInSec,
            relaxationTimeInSec: arguments.relaxationTimeT1InSec
        )
        switch NMRCalcFactory.shared.create(.ernst).process(request) {
        case .success(let response):
            guard let response = response as? ErnstAngleResponse else { throw NMRCalcError.invalidOutput }
            return "Ernst angle: \(String(format: "%.4f", response.ernstAngleInDegree))°, Repetition time: \(String(format: "%.4f", response.repetitionTimeInSec)) s, T1: \(String(format: "%.4f", response.relaxationTimeInSec)) s"
        case .failure(let error):
            Self.logger.error("Failed to process \(String(describing: request)): \(error.localizedDescription)")
            throw error
        }
    }
}
