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
    let description = "Calculates RF pulse amplitude in Hz and µT for a nucleus. Provide the nucleus and two of: duration, flip angle, amplitude."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C'")
        var nucleusIdentifier: String
        @Guide(description: "Pulse duration in microseconds; omit to calculate it")
        var durationInMicrosec: Double?
        @Guide(description: "Flip angle in degrees; omit to calculate it")
        var flipAngleInDegree: Double?
        @Guide(description: "RF amplitude in Hz; omit to calculate it")
        var amplitudeInHz: Double?
    }

    func call(arguments: Arguments) async throws -> String {
        guard let nucleus = await MainActor.run(body: {
            NMRPeriodicTable.shared.nucleus(matching: arguments.nucleusIdentifier)
        }) else {
            return "Nucleus '\(arguments.nucleusIdentifier)' not found."
        }
        let request = PulseParameterRequest(
            durationInMicrosecond: arguments.durationInMicrosec,
            flipAngleInDegree: arguments.flipAngleInDegree,
            amplitudeInHz: arguments.amplitudeInHz
        )
        switch NMRCalcFactory.shared.create(.pulse).process(request) {
        case .success(let r):
            guard let r = r as? PulseParameterResponse else { throw NMRCalcError.invalidOutput }
            let b1InMicroTesla = r.amplitudeInHz / nucleus.γ
            return "Duration: \(String(format: "%.4f", r.durationInMicrosecond)) µs, Flip angle: \(String(format: "%.2f", r.flipAngleInDegree))°, RF amplitude: \(String(format: "%.2f", r.amplitudeInHz)) Hz (\(String(format: "%.4f", b1InMicroTesla)) µT)"
        case .failure(let error):
            Self.logger.error("Failed to process \(String(describing: request)): \(error.localizedDescription)")
            throw error
        }
    }
}
