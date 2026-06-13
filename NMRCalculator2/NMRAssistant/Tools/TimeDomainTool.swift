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
        @Guide(description: "Acquisition time; omit if acquisition time is what the user wants to calculate")
        var acquisitionTime: Double?
        @Guide(description: "Unit of the acquisition time; omit if not stated")
        var acquisitionTimeUnit: TimeUnit?
        @Guide(description: "Number of data points; omit if point count is what the user wants to calculate", .minimum(1))
        var numberOfPoints: Int?
        @Guide(description: "Dwell time; omit if dwell time is what the user wants to calculate")
        var dwellTime: Double?
        @Guide(description: "Unit of the dwell time; omit if not stated")
        var dwellTimeUnit: TimeUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        let acquisitionTime = arguments.acquisitionTime.flatMap { $0 == 0.0 ? nil : $0 }
        let numberOfPoints = arguments.numberOfPoints.flatMap { $0 == 0 ? nil : $0 }
        let dwellTime = arguments.dwellTime.flatMap { $0 == 0.0 ? nil : $0 }

        let providedCount = [acquisitionTime != nil,
                             numberOfPoints != nil,
                             dwellTime != nil].filter { $0 }.count
        guard providedCount == 2 else {
            return "Provide exactly two of: acquisition time, number of points, dwell time; set to nil the one to calculate."
        }

        let acquisitionTimeInSec: Double?
        let dwellInSec: Double?
        do {
            acquisitionTimeInSec = try Self.seconds(acquisitionTime, unit: arguments.acquisitionTimeUnit, assuming: .seconds)
            dwellInSec = try Self.seconds(dwellTime, unit: arguments.dwellTimeUnit, assuming: .microseconds)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        if let acquisitionTimeInSec, acquisitionTimeInSec <= 0 {
            return "Invalid acquisition time \(acquisitionTimeInSec) s: it must be positive. Pass the user's stated value, or set it to nil to calculate it; never pass 0 as a placeholder."
        }
        if let numberOfPoints, numberOfPoints < 1 {
            return "Invalid number of points \(numberOfPoints): it must be a positive integer. Pass the user's stated value, or set it to nil to calculate it; never pass 0 as a placeholder."
        }
        if let dwellInSec, dwellInSec <= 0 {
            return "Invalid dwell time \(dwellInSec) s: it must be positive. Pass the user's stated value, or set it to nil to calculate it; never pass 0 as a placeholder."
        }

        let calculated: ToolResponseEvaluator.TimeDomainParameter = acquisitionTimeInSec == nil
            ? .acquisitionTime
            : (numberOfPoints == nil ? .numberOfPoints : .dwellTime)

        let request = TimeDomainRequest(
            acqusitionTimeInSec: acquisitionTimeInSec,
            numberOfPoints: numberOfPoints,
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

    private static func seconds(_ value: Double?, unit: TimeUnit?, assuming defaultUnit: TimeUnit) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.seconds(from: value, unit: unit, assuming: defaultUnit)
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
