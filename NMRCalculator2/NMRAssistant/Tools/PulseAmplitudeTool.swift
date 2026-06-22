//
//  PulseAmplitudeTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

@Generable
enum PulseAmplitudeTarget {
    case duration
    case flipAngle
    case amplitude
}

struct PulseAmplitudeTool: Tool {
    private static let logger = Logger()

    let name = "calculate_pulse_amplitude"
    let description = "Calculates RF pulse duration, flip angle, or amplitude for a nucleus. Set 'calculate' to the parameter you want computed, then provide the nucleus and the other two with their units."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C'")
        var nucleusIdentifier: String
        @Guide(description: "The parameter to calculate")
        var calculate: PulseAmplitudeTarget
        @Guide(description: "Pulse duration")
        var duration: Double?
        @Guide(description: "Unit of the pulse duration; omit if not stated")
        var durationUnit: TimeUnit?
        @Guide(description: "Flip angle")
        var flipAngle: Double?
        @Guide(description: "Unit of the flip angle; omit if not stated")
        var flipAngleUnit: AngleUnit?
        @Guide(description: "RF amplitude")
        var amplitude: Double?
        @Guide(description: "Unit of the RF amplitude; omit if not stated")
        var amplitudeUnit: FrequencyUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        guard let nucleus = await MainActor.run(body: {
            NMRPeriodicTable.shared.nucleus(matching: arguments.nucleusIdentifier)
        }) else {
            return "Nucleus '\(arguments.nucleusIdentifier)' not found. Use list_nuclei to find valid identifiers."
        }

        let duration = arguments.duration.flatMap { $0 == 0.0 ? nil : $0 }
        let flipAngle = arguments.flipAngle.flatMap { $0 == 0.0 ? nil : $0 }
        let amplitude = arguments.amplitude.flatMap { $0 == 0.0 ? nil : $0 }

        let durationInMicrosec: Double?
        let flipAngleInDegree: Double?
        let amplitudeInHz: Double?
        do {
            durationInMicrosec = try Self.microseconds(duration, unit: arguments.durationUnit)
            flipAngleInDegree = try Self.degrees(flipAngle, unit: arguments.flipAngleUnit)
            amplitudeInHz = try Self.hertz(amplitude, unit: arguments.amplitudeUnit)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        let calculated: ToolResponseEvaluator.PulseParameter
        let request: PulseParameterRequest

        switch arguments.calculate {
        case .duration:
            guard let angle = flipAngleInDegree, angle > 0 else {
                return "Flip angle is required to calculate pulse duration. Provide a positive value with its unit."
            }
            guard let amp = amplitudeInHz, amp > 0 else {
                return "RF amplitude is required to calculate pulse duration. Provide a positive value with its unit."
            }
            calculated = .duration
            request = PulseParameterRequest(durationInMicrosecond: nil, flipAngleInDegree: angle, amplitudeInHz: amp)

        case .flipAngle:
            guard let dur = durationInMicrosec, dur > 0 else {
                return "Pulse duration is required to calculate flip angle. Provide a positive value with its unit."
            }
            guard let amp = amplitudeInHz, amp > 0 else {
                return "RF amplitude is required to calculate flip angle. Provide a positive value with its unit."
            }
            calculated = .flipAngle
            request = PulseParameterRequest(durationInMicrosecond: dur, flipAngleInDegree: nil, amplitudeInHz: amp)

        case .amplitude:
            guard let dur = durationInMicrosec, dur > 0 else {
                return "Pulse duration is required to calculate RF amplitude. Provide a positive value with its unit."
            }
            guard let angle = flipAngleInDegree, angle > 0 else {
                return "Flip angle is required to calculate RF amplitude. Provide a positive value with its unit."
            }
            calculated = .amplitude
            request = PulseParameterRequest(durationInMicrosecond: dur, flipAngleInDegree: angle, amplitudeInHz: nil)
        }

        switch NMRCalcFactory.shared.create(.pulse).process(request) {
        case .success(let response):
            guard let response = response as? PulseParameterResponse else { throw NMRCalcError.invalidOutput }
            guard ToolResponseEvaluator.verify(response, calculated: calculated) else {
                Self.logger.error("Round-trip verification failed for \(String(describing: response))")
                throw NMRCalcError.invalidOutput
            }
            return Self.format(response, calculated: calculated, nucleus: nucleus)
        case .failure(let error):
            Self.logger.error("Failed to process \(String(describing: request)): \(error.localizedDescription)")
            throw error
        }
    }

    private static func microseconds(_ value: Double?, unit: TimeUnit?) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.seconds(from: value, unit: unit, assuming: .microseconds) * 1_000_000.0
    }

    private static func degrees(_ value: Double?, unit: AngleUnit?) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.degrees(from: value, unit: unit)
    }

    private static func hertz(_ value: Double?, unit: FrequencyUnit?) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.hertz(from: value, unit: unit, assuming: .hertz)
    }

    private static func format(_ response: PulseParameterResponse, calculated: ToolResponseEvaluator.PulseParameter, nucleus: NMRNucleus) -> String {
        let b1InMicroTesla = response.amplitudeInHz / abs(nucleus.γ)
        let duration = "pulse duration = \(String(format: "%.4f", response.durationInMicrosecond)) µs"
        let flipAngle = "flip angle = \(String(format: "%.2f", response.flipAngleInDegree)) degrees"
        let amplitude = "RF amplitude = \(String(format: "%.2f", response.amplitudeInHz)) Hz (\(String(format: "%.4f", b1InMicroTesla)) µT)"
        switch calculated {
        case .duration:
            return "Calculated \(duration) (given \(flipAngle), \(amplitude))"
        case .flipAngle:
            return "Calculated \(flipAngle) (given \(duration), \(amplitude))"
        case .amplitude:
            return "Calculated \(amplitude) (given \(duration), \(flipAngle))"
        }
    }
}
