//
//  NMRAssistantToolTests.swift
//  NMRCalculator2Tests
//
//  Direct call(arguments:) tests for the NMR assistant tools. Arguments are
//  built from JSON via GeneratedContent — the same decoding path the
//  FoundationModels runtime uses — so no language model is required.
//

import XCTest
import FoundationModels
import NMRCalculatorCommon
@testable import NMRCalculator2

final class NMRAssistantToolTests: XCTestCase {

    private func arguments<T: ConvertibleFromGeneratedContent>(_ json: String) throws -> T {
        try T(GeneratedContent(json: json))
    }

    // MARK: - ErnstAngleTool

    func testErnstAngleToolCalculatesAngleAndConvertsMilliseconds() async throws {
        let tool = ErnstAngleTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "ernstAngle",
             "relaxationTimeT1": 1500.0, "relaxationTimeT1Unit": "milliseconds",
             "repetitionTime": 1.0, "repetitionTimeUnit": "seconds"}
            """))
        let expected = acos(exp(-1.0 / 1.5)) * 180.0 / Double.pi
        XCTAssertTrue(output.hasPrefix("Calculated Ernst angle = \(String(format: "%.4f", expected)) degrees"), output)
        XCTAssertTrue(output.contains("given repetition time = 1.0000 s, T1 relaxation time = 1.5000 s"), output)
    }

    func testErnstAngleToolCalculatesRepetitionTimeFromRadians() async throws {
        let tool = ErnstAngleTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "repetitionTime",
             "relaxationTimeT1": 2.0, "ernstAngle": \(Double.pi / 4.0), "ernstAngleUnit": "radians"}
            """))
        let expected = -2.0 * log(cos(Double.pi / 4.0))
        XCTAssertTrue(output.hasPrefix("Calculated repetition time = \(String(format: "%.4f", expected)) s"), output)
    }

    func testErnstAngleToolCalculatesRelaxationTime() async throws {
        let tool = ErnstAngleTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "relaxationTimeT1",
             "repetitionTime": 1.0, "ernstAngle": 45.0, "ernstAngleUnit": "degrees"}
            """))
        let expected = -1.0 / log(cos(45.0 * Double.pi / 180.0))
        XCTAssertTrue(output.hasPrefix("Calculated T1 relaxation time = \(String(format: "%.4f", expected)) s"), output)
    }

    func testErnstAngleToolRejectsMissingInputs() async throws {
        let tool = ErnstAngleTool()
        let missingTR = try await tool.call(arguments: arguments("""
            {"calculate": "ernstAngle", "relaxationTimeT1": 1.5}
            """))
        XCTAssertTrue(missingTR.hasPrefix("Repetition time is required to calculate the Ernst angle"), missingTR)

        let missingT1 = try await tool.call(arguments: arguments("""
            {"calculate": "repetitionTime", "ernstAngle": 45.0}
            """))
        XCTAssertTrue(missingT1.hasPrefix("T1 relaxation time is required to calculate the repetition time"), missingT1)
    }

    func testErnstAngleToolRejectsUnrecognizedUnit() async throws {
        let tool = ErnstAngleTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "ernstAngle",
             "relaxationTimeT1": 1.5, "relaxationTimeT1Unit": "unrecognized", "repetitionTime": 1.0}
            """))
        XCTAssertTrue(output.contains("not recognized as a valid time unit"), output)
    }

    func testErnstAngleToolRejectsPlaceholderZeroAndOutOfRangeAngle() async throws {
        let tool = ErnstAngleTool()
        // 0.0 is normalized to nil, so T1 is treated as missing.
        let zero = try await tool.call(arguments: arguments("""
            {"calculate": "ernstAngle", "relaxationTimeT1": 0.0, "repetitionTime": 1.0}
            """))
        XCTAssertTrue(zero.hasPrefix("T1 relaxation time is required to calculate the Ernst angle"), zero)

        let outOfRange = try await tool.call(arguments: arguments("""
            {"calculate": "repetitionTime", "relaxationTimeT1": 1.5, "ernstAngle": 90.0}
            """))
        XCTAssertTrue(outOfRange.hasPrefix("Ernst angle is required to calculate the repetition time"), outOfRange)
    }

    // MARK: - FrequencyDomainTool

    func testFrequencyDomainToolCalculatesResolutionAssumingKilohertz() async throws {
        let tool = FrequencyDomainTool()
        // Spectral width without a unit is taken as kHz.
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "frequencyResolution", "spectralWidth": 10.0, "numberOfPoints": 1024}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated frequency resolution = 9.7656 Hz"), output)
        XCTAssertTrue(output.contains("given spectral width = 10.0000 kHz, number of points = 1024"), output)
    }

    func testFrequencyDomainToolCalculatesSpectralWidth() async throws {
        let tool = FrequencyDomainTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "spectralWidth",
             "numberOfPoints": 1000, "frequencyResolution": 10.0, "frequencyResolutionUnit": "hertz"}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated spectral width = 10.0000 kHz"), output)
    }

    func testFrequencyDomainToolCalculatesNumberOfPoints() async throws {
        let tool = FrequencyDomainTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "numberOfPoints",
             "spectralWidth": 10.0, "spectralWidthUnit": "kilohertz", "frequencyResolution": 9.7}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated number of points = 1030"), output)
    }

    func testFrequencyDomainToolConvertsMegahertz() async throws {
        let tool = FrequencyDomainTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "frequencyResolution",
             "spectralWidth": 0.01, "spectralWidthUnit": "megahertz", "numberOfPoints": 1000}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated frequency resolution = 10.0000 Hz"), output)
    }

    func testFrequencyDomainToolRejectsInvalidArguments() async throws {
        let tool = FrequencyDomainTool()
        let missingSpectralWidth = try await tool.call(arguments: arguments("""
            {"calculate": "frequencyResolution", "numberOfPoints": 1000}
            """))
        XCTAssertTrue(missingSpectralWidth.hasPrefix("Spectral width is required to calculate frequency resolution"), missingSpectralWidth)

        // 0.0 is normalized to nil, treated as missing.
        let zero = try await tool.call(arguments: arguments("""
            {"calculate": "frequencyResolution", "spectralWidth": 0.0, "numberOfPoints": 1000}
            """))
        XCTAssertTrue(zero.hasPrefix("Spectral width is required to calculate frequency resolution"), zero)
    }

    // MARK: - TimeDomainTool

    func testTimeDomainToolCalculatesAcquisitionTimeAssumingMicroseconds() async throws {
        let tool = TimeDomainTool()
        // Dwell time without a unit is taken as µs.
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "acquisitionTime", "numberOfPoints": 1024, "dwellTime": 10.0}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated acquisition time = 0.010240 s"), output)
        XCTAssertTrue(output.contains("given number of points = 1024, dwell time = 10.0000 µs"), output)
    }

    func testTimeDomainToolCalculatesDwellTime() async throws {
        let tool = TimeDomainTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "dwellTime",
             "acquisitionTime": 1.0, "acquisitionTimeUnit": "seconds", "numberOfPoints": 1000}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated dwell time = 1000.0000 µs"), output)
    }

    func testTimeDomainToolCalculatesNumberOfPointsAndConvertsMilliseconds() async throws {
        let tool = TimeDomainTool()
        let output = try await tool.call(arguments: arguments("""
            {"calculate": "numberOfPoints",
             "acquisitionTime": 10.0, "acquisitionTimeUnit": "milliseconds",
             "dwellTime": 10.0, "dwellTimeUnit": "microseconds"}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated number of points = 1000"), output)
    }

    func testTimeDomainToolRejectsInvalidArguments() async throws {
        let tool = TimeDomainTool()
        let missingDwell = try await tool.call(arguments: arguments("""
            {"calculate": "acquisitionTime", "numberOfPoints": 1000}
            """))
        XCTAssertTrue(missingDwell.hasPrefix("Dwell time is required to calculate acquisition time"), missingDwell)

        let unrecognized = try await tool.call(arguments: arguments("""
            {"calculate": "dwellTime",
             "acquisitionTime": 1.0, "acquisitionTimeUnit": "unrecognized", "numberOfPoints": 1000}
            """))
        XCTAssertTrue(unrecognized.contains("not recognized as a valid time unit"), unrecognized)
    }

    // MARK: - LarmorFrequencyTool

    @MainActor
    func testLarmorFrequencyToolCalculatesFromMagneticField() async throws {
        let nucleus = try XCTUnwrap(NMRPeriodicTable.shared.nucleus(matching: "1H"))
        let tool = LarmorFrequencyTool()
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "given": "magneticField",
             "magneticField": 9.4, "magneticFieldUnit": "tesla"}
            """))
        let expected = String(format: "%.4f", nucleus.γ * 9.4)
        XCTAssertTrue(output.hasPrefix("Calculated 1H Larmor frequency = \(expected) MHz"), output)
        XCTAssertTrue(output.contains("given magnetic field B0 = 9.4000 T"), output)
    }

    @MainActor
    func testLarmorFrequencyToolConvertsMillitesla() async throws {
        let nucleus = try XCTUnwrap(NMRPeriodicTable.shared.nucleus(matching: "1H"))
        let tool = LarmorFrequencyTool()
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "given": "magneticField",
             "magneticField": 9400.0, "magneticFieldUnit": "millitesla"}
            """))
        let expected = String(format: "%.4f", nucleus.γ * 9.4)
        XCTAssertTrue(output.hasPrefix("Calculated 1H Larmor frequency = \(expected) MHz"), output)
    }

    @MainActor
    func testLarmorFrequencyToolCalculatesFieldFromLarmorFrequency() async throws {
        let nucleus = try XCTUnwrap(NMRPeriodicTable.shared.nucleus(matching: "13C"))
        let tool = LarmorFrequencyTool()
        // "Carbon-13" exercises the nucleus(matching:) normalization path.
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "Carbon-13", "given": "larmorFrequency",
             "larmorFrequency": 100.0, "larmorFrequencyUnit": "megahertz"}
            """))
        let expected = String(format: "%.4f", 100.0 / nucleus.γ)
        XCTAssertTrue(output.hasPrefix("Calculated magnetic field B0 = \(expected) T"), output)
        XCTAssertTrue(output.contains("given 13C Larmor frequency = 100.0000 MHz"), output)
    }

    @MainActor
    func testLarmorFrequencyToolCalculatesFromProtonFrequency() async throws {
        let tool = LarmorFrequencyTool()
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "13C", "given": "protonFrequency", "protonFrequency": 600.0}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated 13C Larmor frequency = "), output)
        XCTAssertTrue(output.contains("given proton frequency = 600.0000 MHz"), output)
    }

    func testLarmorFrequencyToolRejectsInvalidArguments() async throws {
        let tool = LarmorFrequencyTool()
        let unknown = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "123Xx", "given": "magneticField", "magneticField": 9.4}
            """))
        XCTAssertTrue(unknown.contains("not found"), unknown)

        // 0.0 is normalized to nil, treated as missing.
        let zero = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "given": "magneticField", "magneticField": 0.0}
            """))
        XCTAssertTrue(zero.hasPrefix("Magnetic field is required"), zero)
    }

    // MARK: - PulseAmplitudeTool

    @MainActor
    func testPulseAmplitudeToolCalculatesAmplitudeWithMicroTesla() async throws {
        let nucleus = try XCTUnwrap(NMRPeriodicTable.shared.nucleus(matching: "1H"))
        let tool = PulseAmplitudeTool()
        // Duration without a unit is taken as µs; flip angle as degrees.
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "calculate": "amplitude",
             "duration": 10.0, "flipAngle": 90.0}
            """))
        let b1InMicroTesla = String(format: "%.4f", 25000.0 / nucleus.γ)
        XCTAssertTrue(output.hasPrefix("Calculated RF amplitude = 25000.00 Hz (\(b1InMicroTesla) µT)"), output)
        XCTAssertTrue(output.contains("given pulse duration = 10.0000 µs, flip angle = 90.00 degrees"), output)
    }

    func testPulseAmplitudeToolCalculatesDurationFromKilohertz() async throws {
        let tool = PulseAmplitudeTool()
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "calculate": "duration",
             "flipAngle": 90.0, "amplitude": 1.0, "amplitudeUnit": "kilohertz"}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated pulse duration = 250.0000 µs"), output)
    }

    func testPulseAmplitudeToolCalculatesFlipAngle() async throws {
        let tool = PulseAmplitudeTool()
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "calculate": "flipAngle",
             "duration": 10.0, "durationUnit": "microseconds",
             "amplitude": 25.0, "amplitudeUnit": "kilohertz"}
            """))
        XCTAssertTrue(output.hasPrefix("Calculated flip angle = 90.00 degrees"), output)
    }

    func testPulseAmplitudeToolRejectsInvalidArguments() async throws {
        let tool = PulseAmplitudeTool()
        let unknown = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "123Xx", "calculate": "amplitude",
             "duration": 10.0, "flipAngle": 90.0}
            """))
        XCTAssertTrue(unknown.contains("not found"), unknown)

        let missingFlipAngle = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "calculate": "amplitude", "duration": 10.0}
            """))
        XCTAssertTrue(missingFlipAngle.hasPrefix("Flip angle is required to calculate RF amplitude"), missingFlipAngle)

        // 0.0 is normalized to nil, treated as missing.
        let zero = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "1H", "calculate": "flipAngle",
             "duration": 10.0, "amplitude": 0.0}
            """))
        XCTAssertTrue(zero.hasPrefix("RF amplitude is required to calculate flip angle"), zero)
    }

    // MARK: - PulseRelativePowerTool

    func testPulseRelativePowerToolCalculatesDecibel() async throws {
        let tool = PulseRelativePowerTool()
        // Doubling the duration at the same flip angle halves the amplitude: -6.0206 dB.
        let output = try await tool.call(arguments: arguments("""
            {"referencePulseDuration": 10.0, "referencePulseFlipAngle": 90.0,
             "measuredPulseDuration": 20.0, "measuredPulseFlipAngle": 90.0}
            """))
        let expected = String(format: "%.4f", 20.0 * log10(0.5))
        XCTAssertTrue(output.hasPrefix("Calculated relative power = \(expected) dB"), output)
    }

    func testPulseRelativePowerToolConvertsMilliseconds() async throws {
        let tool = PulseRelativePowerTool()
        let output = try await tool.call(arguments: arguments("""
            {"referencePulseDuration": 10.0, "referencePulseDurationUnit": "microseconds",
             "referencePulseFlipAngle": 90.0,
             "measuredPulseDuration": 0.02, "measuredPulseDurationUnit": "milliseconds",
             "measuredPulseFlipAngle": 90.0}
            """))
        let expected = String(format: "%.4f", 20.0 * log10(0.5))
        XCTAssertTrue(output.hasPrefix("Calculated relative power = \(expected) dB"), output)
    }

    func testPulseRelativePowerToolRejectsInvalidArguments() async throws {
        let tool = PulseRelativePowerTool()
        let zero = try await tool.call(arguments: arguments("""
            {"referencePulseDuration": 0.0, "referencePulseFlipAngle": 90.0,
             "measuredPulseDuration": 20.0, "measuredPulseFlipAngle": 90.0}
            """))
        XCTAssertTrue(zero.hasPrefix("Invalid pulse parameters"), zero)

        let unrecognized = try await tool.call(arguments: arguments("""
            {"referencePulseDuration": 10.0, "referencePulseDurationUnit": "unrecognized",
             "referencePulseFlipAngle": 90.0,
             "measuredPulseDuration": 20.0, "measuredPulseFlipAngle": 90.0}
            """))
        XCTAssertTrue(unrecognized.contains("not recognized as a valid time unit"), unrecognized)
    }

    // MARK: - NucleusListTool

    func testNucleusListToolListsIsotopesByElementNameAndSymbol() async throws {
        let tool = NucleusListTool()
        let byName = try await tool.call(arguments: arguments("""
            {"elementNameOrSymbol": "Carbon"}
            """))
        XCTAssertTrue(byName.contains("13C: spin"), byName)

        let bySymbol = try await tool.call(arguments: arguments("""
            {"elementNameOrSymbol": "C"}
            """))
        XCTAssertEqual(byName, bySymbol)
    }

    func testNucleusListToolReportsNoMatches() async throws {
        let tool = NucleusListTool()
        let output = try await tool.call(arguments: arguments("""
            {"elementNameOrSymbol": "Unobtainium"}
            """))
        XCTAssertTrue(output.hasPrefix("No NMR-active isotopes found"), output)
    }

    // MARK: - OpenNucleusDetailTool

    @MainActor
    func testOpenNucleusDetailToolSetsNavigationState() async throws {
        let navigationState = NMRAssistantNavigationState()
        let tool = OpenNucleusDetailTool(navigationState: navigationState)
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "13C"}
            """))
        XCTAssertEqual(output, "Opening detail view for 13C.")
        XCTAssertEqual(navigationState.requestedNucleusID, "13C")
    }

    @MainActor
    func testOpenNucleusDetailToolRejectsUnknownNucleus() async throws {
        let navigationState = NMRAssistantNavigationState()
        let tool = OpenNucleusDetailTool(navigationState: navigationState)
        let output = try await tool.call(arguments: arguments("""
            {"nucleusIdentifier": "123Xx"}
            """))
        XCTAssertTrue(output.contains("not found"), output)
        XCTAssertNil(navigationState.requestedNucleusID)
    }
}
