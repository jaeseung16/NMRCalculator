//
//  ErnstAngleTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct ErnstAngleTool: Tool {
    let name = "calculate_ernst_angle"
    let description = "Calculates Ernst angle (°) or repetition time (s). Provide T1 and one of: repetition time or Ernst angle."

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
        case .success(let r):
            guard let r = r as? ErnstAngleResponse else { throw NMRCalcError.invalidOutput }
            return "Ernst angle: \(String(format: "%.4f", r.ernstAngleInDegree))°, Repetition time: \(String(format: "%.4f", r.repetitionTimeInSec)) s, T1: \(String(format: "%.4f", r.relaxationTimeInSec)) s"
        case .failure(let error):
            throw error
        }
    }
}
