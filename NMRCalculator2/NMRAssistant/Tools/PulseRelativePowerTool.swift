//
//  PulseRelativePowerTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

struct PulseRelativePowerTool: Tool {
    private static let logger = Logger()

    let name = "calculate_pulse_relative_power"
    let description = "Calculates relative power in dB between two pulses defined by duration and flip angle, with units as the user stated."

    @Generable
    struct Arguments {
        @Guide(description: "Reference pulse duration")
        var referencePulseDuration: Double
        @Guide(description: "Reference pulse duration unit as the user stated it, e.g. 'µs', 'ms'")
        var referencePulseDurationUnit: String?
        @Guide(description: "Reference pulse flip angle")
        var referencePulseFlipAngle: Double
        @Guide(description: "Reference pulse flip angle unit as the user stated it, e.g. 'degree'")
        var referencePulseFlipAngleUnit: String?
        @Guide(description: "Measured pulse duration")
        var measuredPulseDuration: Double
        @Guide(description: "Measured pulse duration unit as the user stated it, e.g. 'µs', 'ms'")
        var measuredPulseDurationUnit: String?
        @Guide(description: "Measured pulse flip angle")
        var measuredPulseFlipAngle: Double
        @Guide(description: "Measured pulse flip angle unit as the user stated it, e.g. 'degree'")
        var measuredPulseFlipAngleUnit: String?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        let referenceDurationInMicrosec: Double
        let referenceFlipAngleInDegree: Double
        let measuredDurationInMicrosec: Double
        let measuredFlipAngleInDegree: Double
        do {
            referenceDurationInMicrosec = try await UnitNormalizer.seconds(from: arguments.referencePulseDuration, unit: arguments.referencePulseDurationUnit, assuming: .microseconds) * 1_000_000.0
            referenceFlipAngleInDegree = try await UnitNormalizer.degrees(from: arguments.referencePulseFlipAngle, unit: arguments.referencePulseFlipAngleUnit)
            measuredDurationInMicrosec = try await UnitNormalizer.seconds(from: arguments.measuredPulseDuration, unit: arguments.measuredPulseDurationUnit, assuming: .microseconds) * 1_000_000.0
            measuredFlipAngleInDegree = try await UnitNormalizer.degrees(from: arguments.measuredPulseFlipAngle, unit: arguments.measuredPulseFlipAngleUnit)
        } catch UnitNormalizationError.unrecognizedUnit(let unit) {
            return "The unit '\(unit)' was not recognized. Ask the user to restate the value with a standard time or angle unit."
        }

        guard referenceDurationInMicrosec > 0, referenceFlipAngleInDegree > 0,
              measuredDurationInMicrosec > 0, measuredFlipAngleInDegree > 0 else {
            return "Invalid pulse parameters: durations and flip angles must all be positive. Pass the user's stated values; never pass 0 as a placeholder."
        }

        let referenceResponse = try Self.amplitude(durationInMicrosec: referenceDurationInMicrosec, flipAngleInDegree: referenceFlipAngleInDegree)
        let measuredResponse = try Self.amplitude(durationInMicrosec: measuredDurationInMicrosec, flipAngleInDegree: measuredFlipAngleInDegree)

        let dbRequest = DecibelCalcualtionRequest(
            measured: measuredResponse.amplitudeInHz,
            reference: referenceResponse.amplitudeInHz,
            mode: .amplitude
        )
        switch NMRCalcFactory.shared.create(.decibel).process(dbRequest) {
        case .success(let response):
            guard let response = response as? DecibelCalcualtionResponse else { throw NMRCalcError.invalidOutput }
            guard ToolResponseEvaluator.verify(response) else {
                Self.logger.error("Round-trip verification failed for \(String(describing: response))")
                throw NMRCalcError.invalidOutput
            }
            let reference = "reference pulse: \(String(format: "%.4f", referenceResponse.durationInMicrosecond)) µs, \(String(format: "%.2f", referenceResponse.flipAngleInDegree)) degrees, amplitude \(String(format: "%.2f", referenceResponse.amplitudeInHz)) Hz"
            let measured = "measured pulse: \(String(format: "%.4f", measuredResponse.durationInMicrosecond)) µs, \(String(format: "%.2f", measuredResponse.flipAngleInDegree)) degrees, amplitude \(String(format: "%.2f", measuredResponse.amplitudeInHz)) Hz"
            return "Calculated relative power = \(String(format: "%.4f", response.dB)) dB (given \(reference); \(measured))"
        case .failure(let error):
            Self.logger.error("Failed to process \(String(describing: dbRequest)): \(error.localizedDescription)")
            throw error
        }
    }

    private static func amplitude(durationInMicrosec: Double, flipAngleInDegree: Double) throws -> PulseParameterResponse {
        let request = PulseParameterRequest(
            durationInMicrosecond: durationInMicrosec,
            flipAngleInDegree: flipAngleInDegree
        )
        guard case .success(let result) = NMRCalcFactory.shared.create(.pulse).process(request),
              let response = result as? PulseParameterResponse else {
            Self.logger.error("Failed to process \(String(describing: request))")
            throw NMRCalcError.invalidInput
        }
        guard ToolResponseEvaluator.verify(response, calculated: .amplitude) else {
            Self.logger.error("Round-trip verification failed for \(String(describing: response))")
            throw NMRCalcError.invalidOutput
        }
        return response
    }
}
