//
//  ToolResponseEvaluator.swift
//  NMRCalculator2
//

import Foundation
import NMRCalculatorCommon
import os

/// Deterministic round-trip verification of calculator responses.
/// The calculated value is fed back into the calculator to solve for one of
/// the given parameters — deliberately exercising a different code path than
/// the original calculation — and the result must reproduce the given value
/// within a relative tolerance.
struct ToolResponseEvaluator {
    private static let logger = Logger()
    private static let relativeTolerance = 1.0e-6

    // MARK: - Ernst angle

    enum ErnstAngleParameter: String {
        case ernstAngle = "Ernst angle"
        case repetitionTime = "repetition time"
        case relaxationTime = "T1 relaxation time"
    }

    static func verify(_ response: ErnstAngleResponse, calculated: ErnstAngleParameter) -> Bool {
        switch calculated {
        case .ernstAngle:
            // Solve for the repetition time from the calculated angle and the given T1.
            guard let result: ErnstAngleResponse = reprocess(
                ErnstAngleRequest(ernstAngleInDegree: response.ernstAngleInDegree,
                                  relaxationTimeInSec: response.relaxationTimeInSec)
            ) else { return false }
            return isClose(result.repetitionTimeInSec, to: response.repetitionTimeInSec)
        case .repetitionTime, .relaxationTime:
            // Solve for the angle from the times; one of them is the calculated value.
            guard let result: ErnstAngleResponse = reprocess(
                ErnstAngleRequest(repetitionTimeInSec: response.repetitionTimeInSec,
                                  relaxationTimeInSec: response.relaxationTimeInSec)
            ) else { return false }
            return isClose(result.ernstAngleInDegree, to: response.ernstAngleInDegree)
        }
    }

    // MARK: - Frequency domain

    enum FrequencyDomainParameter: String {
        case spectralWidth = "spectral width"
        case numberOfPoints = "number of points"
        case frequencyResolution = "frequency resolution"
    }

    static func verify(_ response: FrequencyDomainResponse, calculated: FrequencyDomainParameter) -> Bool {
        switch calculated {
        case .spectralWidth:
            guard let result: FrequencyDomainResponse = reprocess(
                FrequencyDomainRequest(spectralWidthInHz: response.spectralWidthInHz,
                                       numberOfPoints: response.numberOfPoints)
            ) else { return false }
            return isClose(result.frequencyResolutionInHz, to: response.frequencyResolutionInHz)
        case .frequencyResolution:
            guard let result: FrequencyDomainResponse = reprocess(
                FrequencyDomainRequest(numberOfPoints: response.numberOfPoints,
                                       frequencyResolutionInHz: response.frequencyResolutionInHz)
            ) else { return false }
            return isClose(result.spectralWidthInHz, to: response.spectralWidthInHz)
        case .numberOfPoints:
            // The point count is truncated to an integer, so N·resolution may
            // undershoot the given spectral width by up to one resolution step.
            guard let result: FrequencyDomainResponse = reprocess(
                FrequencyDomainRequest(numberOfPoints: response.numberOfPoints,
                                       frequencyResolutionInHz: response.frequencyResolutionInHz)
            ) else { return false }
            return abs(result.spectralWidthInHz - response.spectralWidthInHz)
                <= response.frequencyResolutionInHz * (1.0 + relativeTolerance)
        }
    }

    // MARK: - Time domain

    enum TimeDomainParameter: String {
        case acquisitionTime = "acquisition time"
        case numberOfPoints = "number of points"
        case dwellTime = "dwell time"
    }

    static func verify(_ response: TimeDomainResponse, calculated: TimeDomainParameter) -> Bool {
        switch calculated {
        case .acquisitionTime:
            guard let result: TimeDomainResponse = reprocess(
                TimeDomainRequest(acqusitionTimeInSec: response.acqusitionTimeInSec,
                                  numberOfPoints: response.numberOfPoints)
            ) else { return false }
            return isClose(result.dwellInSec, to: response.dwellInSec)
        case .dwellTime:
            guard let result: TimeDomainResponse = reprocess(
                TimeDomainRequest(numberOfPoints: response.numberOfPoints,
                                  dwellInSec: response.dwellInSec)
            ) else { return false }
            return isClose(result.acqusitionTimeInSec, to: response.acqusitionTimeInSec)
        case .numberOfPoints:
            // The point count is truncated to an integer, so N·dwell may
            // undershoot the given acquisition time by up to one dwell step.
            guard let result: TimeDomainResponse = reprocess(
                TimeDomainRequest(numberOfPoints: response.numberOfPoints,
                                  dwellInSec: response.dwellInSec)
            ) else { return false }
            return abs(result.acqusitionTimeInSec - response.acqusitionTimeInSec)
                <= response.dwellInSec * (1.0 + relativeTolerance)
        }
    }

    // MARK: - Larmor frequency

    /// The single parameter the user provided; all others were calculated from it.
    enum LarmorFrequencyGivenParameter: String {
        case magneticField = "magnetic field"
        case larmorFrequency = "Larmor frequency"
        case protonFrequency = "proton frequency"
        case electronFrequency = "free electron frequency"
    }

    static func verify(_ response: LarmorFrequencyResponse, given: LarmorFrequencyGivenParameter) -> Bool {
        switch given {
        case .magneticField:
            // Solve the field back from the calculated Larmor frequency.
            guard let result: LarmorFrequencyResponse = reprocess(
                LarmorFrequencyRequest(nucleus: response.nucleus, larmorFrequency: response.larmorFrequency)
            ) else { return false }
            return isClose(result.magneticField, to: response.magneticField)
        case .larmorFrequency:
            guard let result: LarmorFrequencyResponse = reprocess(
                LarmorFrequencyRequest(nucleus: response.nucleus, magneticField: response.magneticField)
            ) else { return false }
            return isClose(result.larmorFrequency, to: response.larmorFrequency)
        case .protonFrequency:
            guard let result: LarmorFrequencyResponse = reprocess(
                LarmorFrequencyRequest(nucleus: response.nucleus, magneticField: response.magneticField)
            ) else { return false }
            return isClose(result.protonFrequency, to: response.protonFrequency)
        case .electronFrequency:
            guard let result: LarmorFrequencyResponse = reprocess(
                LarmorFrequencyRequest(nucleus: response.nucleus, magneticField: response.magneticField)
            ) else { return false }
            return isClose(result.electronFrequency, to: response.electronFrequency)
        }
    }

    // MARK: - Pulse parameters

    enum PulseParameter: String {
        case duration = "pulse duration"
        case flipAngle = "flip angle"
        case amplitude = "RF amplitude"
    }

    static func verify(_ response: PulseParameterResponse, calculated: PulseParameter) -> Bool {
        switch calculated {
        case .duration:
            guard let result: PulseParameterResponse = reprocess(
                PulseParameterRequest(durationInMicrosecond: response.durationInMicrosecond,
                                      amplitudeInHz: response.amplitudeInHz)
            ) else { return false }
            return isClose(result.flipAngleInDegree, to: response.flipAngleInDegree)
        case .flipAngle:
            guard let result: PulseParameterResponse = reprocess(
                PulseParameterRequest(durationInMicrosecond: response.durationInMicrosecond,
                                      flipAngleInDegree: response.flipAngleInDegree)
            ) else { return false }
            return isClose(result.amplitudeInHz, to: response.amplitudeInHz)
        case .amplitude:
            guard let result: PulseParameterResponse = reprocess(
                PulseParameterRequest(flipAngleInDegree: response.flipAngleInDegree,
                                      amplitudeInHz: response.amplitudeInHz)
            ) else { return false }
            return isClose(result.durationInMicrosecond, to: response.durationInMicrosecond)
        }
    }

    // MARK: - Relative power (decibel)

    static func verify(_ response: DecibelCalcualtionResponse) -> Bool {
        // Solve the measured value back from the calculated dB.
        guard let result: DecibelCalcualtionResponse = reprocess(
            DecibelCalcualtionRequest(dB: response.dB, reference: response.reference, mode: response.mode)
        ) else { return false }
        return isClose(result.measured, to: response.measured)
    }

    // MARK: - Shared helpers

    private static func reprocess<R: NMRCalcResponse>(_ request: NMRCalcRequest) -> R? {
        guard case .success(let result) = NMRCalcFactory.shared.create(request.calculationType).process(request),
              let result = result as? R else {
            Self.logger.error("Round-trip request failed for \(String(describing: request))")
            return nil
        }
        return result
    }

    private static func isClose(_ value: Double, to expected: Double) -> Bool {
        guard value.isFinite, expected.isFinite else { return false }
        let scale = max(abs(value), abs(expected))
        return scale == 0.0 || abs(value - expected) <= relativeTolerance * scale
    }
}
