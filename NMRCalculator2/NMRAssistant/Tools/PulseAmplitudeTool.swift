//
//  PulseAmplitudeTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

struct PulseAmplitudeTool: Tool {
    private static let logger = Logger()

    let name = "calculate_pulse_amplitude"
    let description = "Calculates RF pulse duration, flip angle, or amplitude for a nucleus. Provide the nucleus and exactly two of the three, with units as the user stated; omit the one to calculate."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C'")
        var nucleusIdentifier: String
        @Guide(description: "Pulse duration; omit to calculate it")
        var duration: Double?
        @Guide(description: "Pulse duration unit as the user stated it, e.g. 'µs', 'ms'")
        var durationUnit: String?
        @Guide(description: "Flip angle; omit to calculate it")
        var flipAngle: Double?
        @Guide(description: "Flip angle unit as the user stated it, e.g. 'degree'")
        var flipAngleUnit: String?
        @Guide(description: "RF amplitude; omit to calculate it")
        var amplitude: Double?
        @Guide(description: "RF amplitude unit as the user stated it, e.g. 'Hz', 'kHz'")
        var amplitudeUnit: String?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments))")
        guard let nucleus = await MainActor.run(body: {
            NMRPeriodicTable.shared.nucleus(matching: arguments.nucleusIdentifier)
        }) else {
            return "Nucleus '\(arguments.nucleusIdentifier)' not found. Use list_nuclei to find valid identifiers."
        }

        let providedCount = [arguments.duration != nil,
                             arguments.flipAngle != nil,
                             arguments.amplitude != nil].filter { $0 }.count
        guard providedCount == 2 else {
            return "Provide exactly two of: pulse duration, flip angle, RF amplitude; omit the one to calculate."
        }

        let durationInMicrosec: Double?
        let flipAngleInDegree: Double?
        let amplitudeInHz: Double?
        do {
            durationInMicrosec = try await Self.microseconds(arguments.duration, unit: arguments.durationUnit)
            flipAngleInDegree = try await Self.degrees(arguments.flipAngle, unit: arguments.flipAngleUnit)
            amplitudeInHz = try await Self.hertz(arguments.amplitude, unit: arguments.amplitudeUnit)
        } catch UnitNormalizationError.unrecognizedUnit(let unit) {
            return "The unit '\(unit)' was not recognized. Ask the user to restate the value with a standard time, angle, or frequency unit."
        }

        if let durationInMicrosec, durationInMicrosec <= 0 {
            return "Invalid pulse duration \(durationInMicrosec) µs: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let flipAngleInDegree, flipAngleInDegree <= 0 {
            return "Invalid flip angle \(flipAngleInDegree) degrees: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }
        if let amplitudeInHz, amplitudeInHz <= 0 {
            return "Invalid RF amplitude \(amplitudeInHz) Hz: it must be positive. Pass the user's stated value, or omit it to calculate it; never pass 0 as a placeholder."
        }

        let calculated: ToolResponseEvaluator.PulseParameter = durationInMicrosec == nil
            ? .duration
            : (flipAngleInDegree == nil ? .flipAngle : .amplitude)

        let request = PulseParameterRequest(
            durationInMicrosecond: durationInMicrosec,
            flipAngleInDegree: flipAngleInDegree,
            amplitudeInHz: amplitudeInHz
        )
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

    private static func microseconds(_ value: Double?, unit: String?) async throws -> Double? {
        guard let value else { return nil }
        return try await UnitNormalizer.seconds(from: value, unit: unit, assuming: .microseconds) * 1_000_000.0
    }

    private static func degrees(_ value: Double?, unit: String?) async throws -> Double? {
        guard let value else { return nil }
        return try await UnitNormalizer.degrees(from: value, unit: unit)
    }

    private static func hertz(_ value: Double?, unit: String?) async throws -> Double? {
        guard let value else { return nil }
        return try await UnitNormalizer.hertz(from: value, unit: unit, assuming: .hertz)
    }

    private static func format(_ response: PulseParameterResponse, calculated: ToolResponseEvaluator.PulseParameter, nucleus: NMRNucleus) -> String {
        let b1InMicroTesla = response.amplitudeInHz / nucleus.γ
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
