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
    let description = "Calculates Ernst angle, repetition time, or T1 relaxation time. Provide exactly two of the three, each with the unit the user stated; omit the one to calculate."

    @Generable
    struct Arguments {
        @Guide(description: "T1 relaxation time; omit to calculate it")
        var relaxationTimeT1: Double?
        @Guide(description: "T1 unit as the user stated it, e.g. 's', 'ms', 'min'")
        var relaxationTimeT1Unit: String?
        @Guide(description: "Repetition time; omit to calculate it")
        var repetitionTime: Double?
        @Guide(description: "Repetition time unit as the user stated it, e.g. 's', 'ms'")
        var repetitionTimeUnit: String?
        @Guide(description: "Ernst angle; omit to calculate it")
        var ernstAngle: Double?
        @Guide(description: "Ernst angle unit as the user stated it, e.g. 'degree', 'radian'")
        var ernstAngleUnit: String?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        let providedCount = [arguments.relaxationTimeT1 != nil,
                             arguments.repetitionTime != nil,
                             arguments.ernstAngle != nil].filter { $0 }.count
        guard providedCount == 2 else {
            return "Provide exactly two of: T1 relaxation time, repetition time, Ernst angle; omit the one to calculate."
        }

        let relaxationTimeInSec: Double?
        let repetitionTimeInSec: Double?
        let ernstAngleInDegree: Double?
        do {
            relaxationTimeInSec = try await Self.seconds(arguments.relaxationTimeT1, unit: arguments.relaxationTimeT1Unit)
            repetitionTimeInSec = try await Self.seconds(arguments.repetitionTime, unit: arguments.repetitionTimeUnit)
            ernstAngleInDegree = try await Self.degrees(arguments.ernstAngle, unit: arguments.ernstAngleUnit)
        } catch UnitNormalizationError.unrecognizedUnit(let unit) {
            return "The unit '\(unit)' was not recognized. Ask the user to restate the value with a standard time or angle unit."
        }

        if let relaxationTimeInSec, relaxationTimeInSec <= 0 {
            return "Invalid T1 relaxation time \(relaxationTimeInSec) s: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let repetitionTimeInSec, repetitionTimeInSec <= 0 {
            return "Invalid repetition time \(repetitionTimeInSec) s: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let ernstAngleInDegree, ernstAngleInDegree <= 0 || ernstAngleInDegree >= 90 {
            return "Invalid Ernst angle \(ernstAngleInDegree) degrees: it must be between 0 and 90 degrees, exclusive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }

        let calculated: ToolResponseEvaluator.ErnstAngleParameter = ernstAngleInDegree == nil
            ? .ernstAngle
            : (repetitionTimeInSec == nil ? .repetitionTime : .relaxationTime)

        let request = ErnstAngleRequest(
            ernstAngleInDegree: ernstAngleInDegree,
            repetitionTimeInSec: repetitionTimeInSec,
            relaxationTimeInSec: relaxationTimeInSec
        )
        switch NMRCalcFactory.shared.create(.ernst).process(request) {
        case .success(let response):
            guard let response = response as? ErnstAngleResponse else { throw NMRCalcError.invalidOutput }
            guard ToolResponseEvaluator.verify(response, calculated: calculated) else {
                Self.logger.error("Round-trip verification failed for \(String(describing: response))")
                throw NMRCalcError.invalidOutput
            }
            return Self.format(response, calculated: calculated)
        case .failure(let error):
            Self.logger.error("Failed to process \(String(describing: request)): \(error.localizedDescription)")
            throw error
        }
    }

    private static func seconds(_ value: Double?, unit: String?) async throws -> Double? {
        guard let value else { return nil }
        return try await UnitNormalizer.seconds(from: value, unit: unit)
    }

    private static func degrees(_ value: Double?, unit: String?) async throws -> Double? {
        guard let value else { return nil }
        return try await UnitNormalizer.degrees(from: value, unit: unit)
    }

    private static func format(_ response: ErnstAngleResponse, calculated: ToolResponseEvaluator.ErnstAngleParameter) -> String {
        let angle = "Ernst angle = \(String(format: "%.4f", response.ernstAngleInDegree)) degrees"
        let repetition = "repetition time = \(String(format: "%.4f", response.repetitionTimeInSec)) s"
        let relaxation = "T1 relaxation time = \(String(format: "%.4f", response.relaxationTimeInSec)) s"
        switch calculated {
        case .ernstAngle:
            return "Calculated \(angle) (given \(repetition), \(relaxation))"
        case .repetitionTime:
            return "Calculated \(repetition) (given \(angle), \(relaxation))"
        case .relaxationTime:
            return "Calculated \(relaxation) (given \(angle), \(repetition))"
        }
    }
}
