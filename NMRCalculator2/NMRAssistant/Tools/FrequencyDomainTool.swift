//
//  FrequencyDomainTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

@Generable
enum FrequencyDomainTarget {
    case spectralWidth
    case numberOfPoints
    case frequencyResolution
}

struct FrequencyDomainTool: Tool {
    private static let logger = Logger()

    let name = "calculate_frequency_domain"
    let description = "Calculates spectral width, frequency resolution, or number of spectrum points. Set 'calculate' to the parameter you want computed, then provide the other two with their units."

    @Generable
    struct Arguments {
        @Guide(description: "The parameter to calculate")
        var calculate: FrequencyDomainTarget
        @Guide(description: "Spectral width")
        var spectralWidth: Double?
        @Guide(description: "Unit of the spectral width; omit if not stated")
        var spectralWidthUnit: FrequencyUnit?
        @Guide(description: "Number of data points")
        var numberOfPoints: Int?
        @Guide(description: "Frequency resolution")
        var frequencyResolution: Double?
        @Guide(description: "Unit of the frequency resolution; omit if not stated")
        var frequencyResolutionUnit: FrequencyUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")

        let spectralWidth = arguments.spectralWidth.flatMap { $0 == 0.0 ? nil : $0 }
        let numberOfPoints = arguments.numberOfPoints.flatMap { $0 == 0 ? nil : $0 }
        let frequencyResolution = arguments.frequencyResolution.flatMap { $0 == 0.0 ? nil : $0 }

        let spectralWidthInHz: Double?
        let frequencyResolutionInHz: Double?
        do {
            spectralWidthInHz = try Self.hertz(spectralWidth, unit: arguments.spectralWidthUnit, assuming: .kilohertz)
            frequencyResolutionInHz = try Self.hertz(frequencyResolution, unit: arguments.frequencyResolutionUnit, assuming: .hertz)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        let calculated: ToolResponseEvaluator.FrequencyDomainParameter
        let request: FrequencyDomainRequest

        switch arguments.calculate {
        case .spectralWidth:
            guard let n = numberOfPoints, n > 0 else {
                return "Number of points is required to calculate spectral width. Provide a positive integer."
            }
            guard let res = frequencyResolutionInHz, res > 0 else {
                return "Frequency resolution is required to calculate spectral width. Provide a positive value with its unit."
            }
            calculated = .spectralWidth
            request = FrequencyDomainRequest(spectralWidthInHz: nil, numberOfPoints: n, frequencyResolutionInHz: res)

        case .numberOfPoints:
            guard let sw = spectralWidthInHz, sw > 0 else {
                return "Spectral width is required to calculate number of points. Provide a positive value with its unit."
            }
            guard let res = frequencyResolutionInHz, res > 0 else {
                return "Frequency resolution is required to calculate number of points. Provide a positive value with its unit."
            }
            calculated = .numberOfPoints
            request = FrequencyDomainRequest(spectralWidthInHz: sw, numberOfPoints: nil, frequencyResolutionInHz: res)

        case .frequencyResolution:
            guard let sw = spectralWidthInHz, sw > 0 else {
                return "Spectral width is required to calculate frequency resolution. Provide a positive value with its unit."
            }
            guard let n = numberOfPoints, n > 0 else {
                return "Number of points is required to calculate frequency resolution. Provide a positive integer."
            }
            calculated = .frequencyResolution
            request = FrequencyDomainRequest(spectralWidthInHz: sw, numberOfPoints: n, frequencyResolutionInHz: nil)
        }

        switch NMRCalcFactory.shared.create(.frequency).process(request) {
        case .success(let response):
            guard let response = response as? FrequencyDomainResponse else { throw NMRCalcError.invalidOutput }
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

    private static func hertz(_ value: Double?, unit: FrequencyUnit?, assuming defaultUnit: FrequencyUnit) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.hertz(from: value, unit: unit, assuming: defaultUnit)
    }

    private static func format(_ response: FrequencyDomainResponse, calculated: ToolResponseEvaluator.FrequencyDomainParameter) -> String {
        let spectralWidth = "spectral width = \(String(format: "%.4f", response.spectralWidthInHz / 1000.0)) kHz"
        let points = "number of points = \(response.numberOfPoints)"
        let resolution = "frequency resolution = \(String(format: "%.4f", response.frequencyResolutionInHz)) Hz"
        switch calculated {
        case .spectralWidth:
            return "Calculated \(spectralWidth) (given \(points), \(resolution))"
        case .numberOfPoints:
            return "Calculated \(points) (given \(spectralWidth), \(resolution))"
        case .frequencyResolution:
            return "Calculated \(resolution) (given \(spectralWidth), \(points))"
        }
    }
}
