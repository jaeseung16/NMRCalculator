//
//  TimeDomainTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

struct TimeDomainTool: Tool {
    private static let logger = Logger()

    let name = "calculate_time_domain"
    let description = "Calculates acquisition time, dwell time, or number of acquisition points. Provide exactly two of the three, with units as the user stated; omit the one to calculate."

    @Generable
    struct Arguments {
        @Guide(description: "Acquisition time; omit to calculate it")
        var acquisitionTime: Double?
        @Guide(description: "Acquisition time unit as the user stated it, e.g. 's', 'ms'")
        var acquisitionTimeUnit: String?
        @Guide(description: "Number of data points; omit to calculate it", .minimum(1))
        var numberOfPoints: Int?
        @Guide(description: "Dwell time; omit to calculate it")
        var dwellTime: Double?
        @Guide(description: "Dwell time unit as the user stated it, e.g. 'µs', 'ms'")
        var dwellTimeUnit: String?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        let providedCount = [arguments.acquisitionTime != nil,
                             arguments.numberOfPoints != nil,
                             arguments.dwellTime != nil].filter { $0 }.count
        guard providedCount == 2 else {
            return "Provide exactly two of: acquisition time, number of points, dwell time; omit the one to calculate."
        }

        let acquisitionTimeInSec: Double?
        let dwellInSec: Double?
        do {
            acquisitionTimeInSec = try await Self.seconds(arguments.acquisitionTime, unit: arguments.acquisitionTimeUnit, assuming: .seconds)
            dwellInSec = try await Self.seconds(arguments.dwellTime, unit: arguments.dwellTimeUnit, assuming: .microseconds)
        } catch UnitNormalizationError.unrecognizedUnit(let unit) {
            return "The unit '\(unit)' was not recognized. Ask the user to restate the value with a standard time unit."
        }

        if let acquisitionTimeInSec, acquisitionTimeInSec <= 0 {
            return "Invalid acquisition time \(acquisitionTimeInSec) s: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let numberOfPoints = arguments.numberOfPoints, numberOfPoints < 1 {
            return "Invalid number of points \(numberOfPoints): it must be a positive integer. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let dwellInSec, dwellInSec <= 0 {
            return "Invalid dwell time \(dwellInSec) s: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }

        let calculated: ToolResponseEvaluator.TimeDomainParameter = acquisitionTimeInSec == nil
            ? .acquisitionTime
            : (arguments.numberOfPoints == nil ? .numberOfPoints : .dwellTime)

        let request = TimeDomainRequest(
            acqusitionTimeInSec: acquisitionTimeInSec,
            numberOfPoints: arguments.numberOfPoints,
            dwellInSec: dwellInSec
        )
        switch NMRCalcFactory.shared.create(.time).process(request) {
        case .success(let response):
            guard let response = response as? TimeDomainResponse else { throw NMRCalcError.invalidOutput }
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

    private static func seconds(_ value: Double?, unit: String?, assuming defaultUnit: TimeUnit) async throws -> Double? {
        guard let value else { return nil }
        return try await UnitNormalizer.seconds(from: value, unit: unit, assuming: defaultUnit)
    }

    private static func format(_ response: TimeDomainResponse, calculated: ToolResponseEvaluator.TimeDomainParameter) -> String {
        let acquisition = "acquisition time = \(String(format: "%.6f", response.acqusitionTimeInSec)) s"
        let points = "number of points = \(response.numberOfPoints)"
        let dwell = "dwell time = \(String(format: "%.4f", response.dwellInSec * 1_000_000.0)) µs"
        switch calculated {
        case .acquisitionTime:
            return "Calculated \(acquisition) (given \(points), \(dwell))"
        case .numberOfPoints:
            return "Calculated \(points) (given \(acquisition), \(dwell))"
        case .dwellTime:
            return "Calculated \(dwell) (given \(acquisition), \(points))"
        }
    }
}
