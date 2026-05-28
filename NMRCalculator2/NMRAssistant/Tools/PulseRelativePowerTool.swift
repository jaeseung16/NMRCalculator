//
//  PulseRelativePowerTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct PulseRelativePowerTool: Tool {
    let name = "calculate_pulse_relative_power"
    let description = "Calculates relative power in dB between two pulses defined by duration and flip angle."

    @Generable
    struct Arguments {
        @Guide(description: "Reference pulse duration in microseconds")
        var referencePulseDurationInMicrosec: Double
        @Guide(description: "Reference pulse flip angle in degrees")
        var referencePulseFlipAngleInDegree: Double
        @Guide(description: "Measured pulse duration in microseconds")
        var measuredPulseDurationInMicrosec: Double
        @Guide(description: "Measured pulse flip angle in degrees")
        var measuredPulseFlipAngleInDegree: Double
    }

    func call(arguments: Arguments) async throws -> String {
        let pulseCalc = NMRCalcFactory.shared.create(.pulse)
        let refRequest = PulseParameterRequest(
            durationInMicrosecond: arguments.referencePulseDurationInMicrosec,
            flipAngleInDegree: arguments.referencePulseFlipAngleInDegree
        )
        let measRequest = PulseParameterRequest(
            durationInMicrosecond: arguments.measuredPulseDurationInMicrosec,
            flipAngleInDegree: arguments.measuredPulseFlipAngleInDegree
        )
        guard case .success(let refR) = pulseCalc.process(refRequest),
              let refResp = refR as? PulseParameterResponse,
              case .success(let measR) = pulseCalc.process(measRequest),
              let measResp = measR as? PulseParameterResponse else {
            throw NMRCalcError.invalidInput
        }
        let dbRequest = DecibelCalcualtionRequest(
            measured: measResp.amplitudeInHz,
            reference: refResp.amplitudeInHz,
            mode: .amplitude
        )
        switch NMRCalcFactory.shared.create(.decibel).process(dbRequest) {
        case .success(let r):
            guard let r = r as? DecibelCalcualtionResponse else { throw NMRCalcError.invalidOutput }
            return "Relative power: \(String(format: "%.4f", r.dB)) dB (ref: \(String(format: "%.2f", refResp.amplitudeInHz)) Hz, measured: \(String(format: "%.2f", measResp.amplitudeInHz)) Hz)"
        case .failure(let error):
            throw error
        }
    }
}
