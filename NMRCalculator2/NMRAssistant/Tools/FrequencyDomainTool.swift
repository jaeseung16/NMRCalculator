//
//  FrequencyDomainTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

struct FrequencyDomainTool: Tool {
    private static let logger = Logger()

    let name = "calculate_frequency_domain"
    let description = "Calculates spectral width, frequency resolution, or number of spectrum points. Provide exactly two of the three, with units as the user stated; omit the one to calculate."

    @Generable
    struct Arguments {
        @Guide(description: "Spectral width; omit to calculate it")
        var spectralWidth: Double?
        @Guide(description: "Unit of the spectral width; omit if not stated")
        var spectralWidthUnit: FrequencyUnit?
        @Guide(description: "Number of data points; omit to calculate it", .minimum(1))
        var numberOfPoints: Int?
        @Guide(description: "Frequency resolution; omit to calculate it")
        var frequencyResolution: Double?
        @Guide(description: "Unit of the frequency resolution; omit if not stated")
        var frequencyResolutionUnit: FrequencyUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        let providedCount = [arguments.spectralWidth != nil,
                             arguments.numberOfPoints != nil,
                             arguments.frequencyResolution != nil].filter { $0 }.count
        guard providedCount == 2 else {
            return "Provide exactly two of: spectral width, number of points, frequency resolution; omit the one to calculate."
        }

        let spectralWidthInHz: Double?
        let frequencyResolutionInHz: Double?
        do {
            spectralWidthInHz = try Self.hertz(arguments.spectralWidth, unit: arguments.spectralWidthUnit, assuming: .kilohertz)
            frequencyResolutionInHz = try Self.hertz(arguments.frequencyResolution, unit: arguments.frequencyResolutionUnit, assuming: .hertz)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        if let spectralWidthInHz, spectralWidthInHz <= 0 {
            return "Invalid spectral width \(spectralWidthInHz) Hz: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let numberOfPoints = arguments.numberOfPoints, numberOfPoints < 1 {
            return "Invalid number of points \(numberOfPoints): it must be a positive integer. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let frequencyResolutionInHz, frequencyResolutionInHz <= 0 {
            return "Invalid frequency resolution \(frequencyResolutionInHz) Hz: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }

        let calculated: ToolResponseEvaluator.FrequencyDomainParameter = spectralWidthInHz == nil
            ? .spectralWidth
            : (arguments.numberOfPoints == nil ? .numberOfPoints : .frequencyResolution)

        let request = FrequencyDomainRequest(
            spectralWidthInHz: spectralWidthInHz,
            numberOfPoints: arguments.numberOfPoints,
            frequencyResolutionInHz: frequencyResolutionInHz
        )
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
