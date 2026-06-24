//
//  ErnstAngleTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

@Generable
enum ErnstAngleTarget {
    case ernstAngle
    case repetitionTime
    case relaxationTimeT1
}

struct ErnstAngleTool: Tool {
    private static let logger = Logger()

    let name = "calculate_ernst_angle"
    let description = "Calculates Ernst angle, repetition time, or T1 relaxation time. Set 'calculate' to the parameter you want computed, then provide the other two with their units."

    @Generable
    struct Arguments {
        @Guide(description: "The parameter to calculate")
        var calculate: ErnstAngleTarget
        @Guide(description: "T1 relaxation time")
        var relaxationTimeT1: Double?
        @Guide(description: "Unit of the T1 relaxation time; omit if not stated")
        var relaxationTimeT1Unit: TimeUnit?
        @Guide(description: "Repetition time")
        var repetitionTime: Double?
        @Guide(description: "Unit of the repetition time; omit if not stated")
        var repetitionTimeUnit: TimeUnit?
        @Guide(description: "Ernst angle")
        var ernstAngle: Double?
        @Guide(description: "Unit of the Ernst angle; omit if not stated")
        var ernstAngleUnit: AngleUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")

        let relaxationTimeT1 = arguments.relaxationTimeT1.flatMap { $0 == 0.0 ? nil : $0 }
        let repetitionTime = arguments.repetitionTime.flatMap { $0 == 0.0 ? nil : $0 }
        let ernstAngle = arguments.ernstAngle.flatMap { $0 == 0.0 ? nil : $0 }

        let relaxationTimeInSec: Double?
        let repetitionTimeInSec: Double?
        let ernstAngleInDegree: Double?
        do {
            relaxationTimeInSec = try Self.seconds(relaxationTimeT1, unit: arguments.relaxationTimeT1Unit)
            repetitionTimeInSec = try Self.seconds(repetitionTime, unit: arguments.repetitionTimeUnit)
            ernstAngleInDegree = try Self.degrees(ernstAngle, unit: arguments.ernstAngleUnit)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        let calculated: ToolResponseEvaluator.ErnstAngleParameter
        let request: ErnstAngleRequest

        switch arguments.calculate {
        case .ernstAngle:
            guard let t1 = relaxationTimeInSec, t1 > 0 else {
                return "T1 relaxation time is required to calculate the Ernst angle. Provide a positive value with its unit."
            }
            guard let tr = repetitionTimeInSec, tr > 0 else {
                return "Repetition time is required to calculate the Ernst angle. Provide a positive value with its unit."
            }
            calculated = .ernstAngle
            request = ErnstAngleRequest(ernstAngleInDegree: nil, repetitionTimeInSec: tr, relaxationTimeInSec: t1)

        case .repetitionTime:
            guard let t1 = relaxationTimeInSec, t1 > 0 else {
                return "T1 relaxation time is required to calculate the repetition time. Provide a positive value with its unit."
            }
            guard let angle = ernstAngleInDegree, angle > 0, angle < 90 else {
                return "Ernst angle is required to calculate the repetition time. Provide a value between 0 and 90 degrees (exclusive)."
            }
            calculated = .repetitionTime
            request = ErnstAngleRequest(ernstAngleInDegree: angle, repetitionTimeInSec: nil, relaxationTimeInSec: t1)

        case .relaxationTimeT1:
            guard let tr = repetitionTimeInSec, tr > 0 else {
                return "Repetition time is required to calculate T1. Provide a positive value with its unit."
            }
            guard let angle = ernstAngleInDegree, angle > 0, angle < 90 else {
                return "Ernst angle is required to calculate T1. Provide a value between 0 and 90 degrees (exclusive)."
            }
            calculated = .relaxationTime
            request = ErnstAngleRequest(ernstAngleInDegree: angle, repetitionTimeInSec: tr, relaxationTimeInSec: nil)
        }

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

    private static func seconds(_ value: Double?, unit: TimeUnit?) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.seconds(from: value, unit: unit)
    }

    private static func degrees(_ value: Double?, unit: AngleUnit?) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.degrees(from: value, unit: unit)
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
