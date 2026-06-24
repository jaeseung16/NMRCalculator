//
//  ToolResponseEvaluatorTests.swift
//  NMRCalculator2Tests
//

import XCTest
import NMRCalculatorCommon
@testable import NMRCalculator2

final class ToolResponseEvaluatorTests: XCTestCase {

    // MARK: - Ernst angle

    private var consistentErnstAngle: ErnstAngleResponse {
        ErnstAngleResponse(
            ernstAngleInDegree: acos(exp(-1.0)) * 180.0 / Double.pi,
            repetitionTimeInSec: 1.0,
            relaxationTimeInSec: 1.0
        )
    }

    func testErnstAngleVerifyAcceptsConsistentResponse() {
        XCTAssertTrue(ToolResponseEvaluator.verify(consistentErnstAngle, calculated: .ernstAngle))
        XCTAssertTrue(ToolResponseEvaluator.verify(consistentErnstAngle, calculated: .repetitionTime))
        XCTAssertTrue(ToolResponseEvaluator.verify(consistentErnstAngle, calculated: .relaxationTime))
    }

    func testErnstAngleVerifyRejectsCorruptedResponse() {
        let corrupted = ErnstAngleResponse(
            ernstAngleInDegree: 45.0,
            repetitionTimeInSec: 1.0,
            relaxationTimeInSec: 1.0
        )
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .ernstAngle))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .repetitionTime))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .relaxationTime))
    }

    // MARK: - Frequency domain

    func testFrequencyDomainVerifyAcceptsConsistentResponse() {
        let response = FrequencyDomainResponse(
            spectralWidthInHz: 10000.0,
            numberOfPoints: 1000,
            frequencyResolutionInHz: 10.0
        )
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .spectralWidth))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .numberOfPoints))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .frequencyResolution))
    }

    func testFrequencyDomainVerifyAcceptsTruncatedPointCount() {
        // N = Int(10000 / 9.7) = 1030, so N·resolution undershoots the given
        // spectral width by 9 Hz — within the one-step tolerance.
        let response = FrequencyDomainResponse(
            spectralWidthInHz: 10000.0,
            numberOfPoints: 1030,
            frequencyResolutionInHz: 9.7
        )
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .numberOfPoints))
    }

    func testFrequencyDomainVerifyRejectsCorruptedResponse() {
        let corrupted = FrequencyDomainResponse(
            spectralWidthInHz: 10000.0,
            numberOfPoints: 1000,
            frequencyResolutionInHz: 9.0
        )
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .spectralWidth))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .numberOfPoints))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .frequencyResolution))
    }

    // MARK: - Time domain

    func testTimeDomainVerifyAcceptsConsistentResponse() {
        let response = TimeDomainResponse(
            acqusitionTimeInSec: 0.01024,
            numberOfPoints: 1024,
            dwellInSec: 1.0e-5
        )
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .acquisitionTime))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .numberOfPoints))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .dwellTime))
    }

    func testTimeDomainVerifyRejectsCorruptedResponse() {
        let corrupted = TimeDomainResponse(
            acqusitionTimeInSec: 0.02,
            numberOfPoints: 1024,
            dwellInSec: 1.0e-5
        )
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .acquisitionTime))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .numberOfPoints))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .dwellTime))
    }

    // MARK: - Larmor frequency

    @MainActor
    func testLarmorFrequencyVerifyAcceptsCalculatorResponse() throws {
        let nucleus = try XCTUnwrap(NMRPeriodicTable.shared.nucleus(matching: "1H"))
        let request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: 9.4)
        guard case .success(let result) = NMRCalcFactory.shared.create(.larmor).process(request),
              let response = result as? LarmorFrequencyResponse else {
            return XCTFail("Larmor calculation failed")
        }
        XCTAssertTrue(ToolResponseEvaluator.verify(response, given: .magneticField))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, given: .larmorFrequency))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, given: .protonFrequency))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, given: .electronFrequency))
    }

    @MainActor
    func testLarmorFrequencyVerifyRejectsCorruptedResponse() throws {
        let nucleus = try XCTUnwrap(NMRPeriodicTable.shared.nucleus(matching: "1H"))
        let request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: 9.4)
        guard case .success(let result) = NMRCalcFactory.shared.create(.larmor).process(request),
              let response = result as? LarmorFrequencyResponse else {
            return XCTFail("Larmor calculation failed")
        }
        let corrupted = LarmorFrequencyResponse(
            nucleus: response.nucleus,
            magneticField: response.magneticField,
            larmorFrequency: response.larmorFrequency * 1.01,
            protonFrequency: response.protonFrequency,
            electronFrequency: response.electronFrequency
        )
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, given: .magneticField))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, given: .larmorFrequency))
    }

    // MARK: - Pulse parameters

    func testPulseParameterVerifyAcceptsConsistentResponse() {
        let response = PulseParameterResponse(
            durationInMicrosecond: 10.0,
            flipAngleInDegree: 90.0,
            amplitudeInHz: 25000.0
        )
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .duration))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .flipAngle))
        XCTAssertTrue(ToolResponseEvaluator.verify(response, calculated: .amplitude))
    }

    func testPulseParameterVerifyRejectsCorruptedResponse() {
        let corrupted = PulseParameterResponse(
            durationInMicrosecond: 10.0,
            flipAngleInDegree: 90.0,
            amplitudeInHz: 30000.0
        )
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .duration))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .flipAngle))
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted, calculated: .amplitude))
    }

    // MARK: - Relative power (decibel)

    func testDecibelVerifyAcceptsConsistentResponse() {
        let amplitude = DecibelCalcualtionResponse(
            dB: 20.0 * log10(2.0),
            measured: 2.0,
            reference: 1.0,
            mode: .amplitude
        )
        XCTAssertTrue(ToolResponseEvaluator.verify(amplitude))

        let power = DecibelCalcualtionResponse(
            dB: 10.0 * log10(4.0),
            measured: 4.0,
            reference: 1.0,
            mode: .power
        )
        XCTAssertTrue(ToolResponseEvaluator.verify(power))
    }

    func testDecibelVerifyRejectsCorruptedResponse() {
        let corrupted = DecibelCalcualtionResponse(
            dB: 5.0,
            measured: 2.0,
            reference: 1.0,
            mode: .amplitude
        )
        XCTAssertFalse(ToolResponseEvaluator.verify(corrupted))
    }
}
