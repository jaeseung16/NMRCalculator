//
//  TimeDomainTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

@Generable
enum TimeDomainTarget {
    case acquisitionTime
    case numberOfPoints
    case dwellTime
}

struct TimeDomainTool: Tool {
    private static let logger = Logger()

    let name = "calculate_time_domain"
    let description = "Calculates acquisition time, dwell time, or number of acquisition points. Set 'calculate' to the parameter you want computed, then provide the other two with their units."

    @Generable
    struct Arguments {
        @Guide(description: "The parameter to calculate")
        var calculate: TimeDomainTarget
        @Guide(description: "Acquisition time")
        var acquisitionTime: Double?
        @Guide(description: "Unit of the acquisition time; omit if not stated")
        var acquisitionTimeUnit: TimeUnit?
        @Guide(description: "Number of data points")
        var numberOfPoints: Int?
        @Guide(description: "Dwell time")
        var dwellTime: Double?
        @Guide(description: "Unit of the dwell time; omit if not stated")
        var dwellTimeUnit: TimeUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")

        let acquisitionTime = arguments.acquisitionTime.flatMap { $0 == 0.0 ? nil : $0 }
        let numberOfPoints = arguments.numberOfPoints.flatMap { $0 == 0 ? nil : $0 }
        let dwellTime = arguments.dwellTime.flatMap { $0 == 0.0 ? nil : $0 }

        let acquisitionTimeInSec: Double?
        let dwellInSec: Double?
        do {
            acquisitionTimeInSec = try Self.seconds(acquisitionTime, unit: arguments.acquisitionTimeUnit, assuming: .seconds)
            dwellInSec = try Self.seconds(dwellTime, unit: arguments.dwellTimeUnit, assuming: .microseconds)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        let calculated: ToolResponseEvaluator.TimeDomainParameter
        let request: TimeDomainRequest

        switch arguments.calculate {
        case .acquisitionTime:
            guard let n = numberOfPoints, n > 0 else {
                return "Number of points is required to calculate acquisition time. Provide a positive integer."
            }
            guard let dwell = dwellInSec, dwell > 0 else {
                return "Dwell time is required to calculate acquisition time. Provide a positive value with its unit."
            }
            calculated = .acquisitionTime
            request = TimeDomainRequest(acqusitionTimeInSec: nil, numberOfPoints: n, dwellInSec: dwell)

        case .numberOfPoints:
            guard let acq = acquisitionTimeInSec, acq > 0 else {
                return "Acquisition time is required to calculate number of points. Provide a positive value with its unit."
            }
            guard let dwell = dwellInSec, dwell > 0 else {
                return "Dwell time is required to calculate number of points. Provide a positive value with its unit."
            }
            calculated = .numberOfPoints
            request = TimeDomainRequest(acqusitionTimeInSec: acq, numberOfPoints: nil, dwellInSec: dwell)

        case .dwellTime:
            guard let acq = acquisitionTimeInSec, acq > 0 else {
                return "Acquisition time is required to calculate dwell time. Provide a positive value with its unit."
            }
            guard let n = numberOfPoints, n > 0 else {
                return "Number of points is required to calculate dwell time. Provide a positive integer."
            }
            calculated = .dwellTime
            request = TimeDomainRequest(acqusitionTimeInSec: acq, numberOfPoints: n, dwellInSec: nil)
        }

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
