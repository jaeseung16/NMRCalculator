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
        @Guide(description: "Unit of the reference pulse duration; omit if not stated")
        var referencePulseDurationUnit: TimeUnit?
        @Guide(description: "Reference pulse flip angle")
        var referencePulseFlipAngle: Double
        @Guide(description: "Unit of the reference pulse flip angle; omit if not stated")
        var referencePulseFlipAngleUnit: AngleUnit?
        @Guide(description: "Measured pulse duration")
        var measuredPulseDuration: Double
        @Guide(description: "Unit of the measured pulse duration; omit if not stated")
        var measuredPulseDurationUnit: TimeUnit?
        @Guide(description: "Measured pulse flip angle")
        var measuredPulseFlipAngle: Double
        @Guide(description: "Unit of the measured pulse flip angle; omit if not stated")
        var measuredPulseFlipAngleUnit: AngleUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        let referenceDurationInMicrosec: Double
        let referenceFlipAngleInDegree: Double
        let measuredDurationInMicrosec: Double
        let measuredFlipAngleInDegree: Double
        do {
            referenceDurationInMicrosec = try UnitNormalizer.seconds(from: arguments.referencePulseDuration, unit: arguments.referencePulseDurationUnit, assuming: .microseconds) * 1_000_000.0
            referenceFlipAngleInDegree = try UnitNormalizer.degrees(from: arguments.referencePulseFlipAngle, unit: arguments.referencePulseFlipAngleUnit)
            measuredDurationInMicrosec = try UnitNormalizer.seconds(from: arguments.measuredPulseDuration, unit: arguments.measuredPulseDurationUnit, assuming: .microseconds) * 1_000_000.0
            measuredFlipAngleInDegree = try UnitNormalizer.degrees(from: arguments.measuredPulseFlipAngle, unit: arguments.measuredPulseFlipAngleUnit)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
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
