//
//  UnitNormalizerTests.swift
//  NMRCalculator2Tests
//

import XCTest
@testable import NMRCalculator2

final class UnitNormalizerTests: XCTestCase {

    private let accuracy = 1.0e-12

    // MARK: - Time

    func testSecondsConversions() throws {
        XCTAssertEqual(try UnitNormalizer.seconds(from: 1.5, unit: .seconds), 1.5, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.seconds(from: 1500.0, unit: .milliseconds), 1.5, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.seconds(from: 10.0, unit: .microseconds), 1.0e-5, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.seconds(from: 250.0, unit: .nanoseconds), 2.5e-7, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.seconds(from: 2.0, unit: .minutes), 120.0, accuracy: accuracy)
    }

    func testSecondsNilUnitUsesAssumedUnit() throws {
        // Default assumption is seconds.
        XCTAssertEqual(try UnitNormalizer.seconds(from: 3.0, unit: nil), 3.0, accuracy: accuracy)
        // A parameter-specific assumption (e.g. dwell time in µs).
        XCTAssertEqual(try UnitNormalizer.seconds(from: 10.0, unit: nil, assuming: .microseconds), 1.0e-5, accuracy: accuracy)
        // A stated unit overrides the assumption.
        XCTAssertEqual(try UnitNormalizer.seconds(from: 10.0, unit: .milliseconds, assuming: .microseconds), 0.01, accuracy: accuracy)
    }

    func testSecondsUnrecognizedUnitThrows() {
        XCTAssertThrowsError(try UnitNormalizer.seconds(from: 1.0, unit: .unrecognized)) { error in
            guard case UnitNormalizationError.unrecognizedUnit(let dimension) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(dimension, "time")
        }
    }

    // MARK: - Angle

    func testDegreesConversions() throws {
        XCTAssertEqual(try UnitNormalizer.degrees(from: 90.0, unit: .degrees), 90.0, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.degrees(from: Double.pi / 2.0, unit: .radians), 90.0, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.degrees(from: 45.0, unit: nil), 45.0, accuracy: accuracy)
    }

    func testDegreesUnrecognizedUnitThrows() {
        XCTAssertThrowsError(try UnitNormalizer.degrees(from: 1.0, unit: .unrecognized)) { error in
            guard case UnitNormalizationError.unrecognizedUnit(let dimension) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(dimension, "angle")
        }
    }

    // MARK: - Frequency

    func testHertzConversions() throws {
        XCTAssertEqual(try UnitNormalizer.hertz(from: 25.0, unit: .hertz), 25.0, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.hertz(from: 1.0, unit: .kilohertz), 1.0e3, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.hertz(from: 400.0, unit: .megahertz), 4.0e8, accuracy: 1.0e-4)
        XCTAssertEqual(try UnitNormalizer.hertz(from: 2.0, unit: .gigahertz), 2.0e9, accuracy: 1.0e-3)
    }

    func testHertzNilUnitUsesAssumedUnit() throws {
        XCTAssertEqual(try UnitNormalizer.hertz(from: 10.0, unit: nil), 10.0, accuracy: accuracy)
        // A parameter-specific assumption (e.g. Larmor frequency in MHz).
        XCTAssertEqual(try UnitNormalizer.hertz(from: 100.0, unit: nil, assuming: .megahertz), 1.0e8, accuracy: 1.0e-4)
        XCTAssertEqual(try UnitNormalizer.hertz(from: 100.0, unit: .kilohertz, assuming: .megahertz), 1.0e5, accuracy: accuracy)
    }

    func testHertzUnrecognizedUnitThrows() {
        XCTAssertThrowsError(try UnitNormalizer.hertz(from: 1.0, unit: .unrecognized)) { error in
            guard case UnitNormalizationError.unrecognizedUnit(let dimension) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(dimension, "frequency")
        }
    }

    // MARK: - Magnetic field

    func testTeslaConversions() throws {
        XCTAssertEqual(try UnitNormalizer.tesla(from: 9.4, unit: .tesla), 9.4, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.tesla(from: 500.0, unit: .millitesla), 0.5, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.tesla(from: 50.0, unit: .microtesla), 5.0e-5, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.tesla(from: 10000.0, unit: .gauss), 1.0, accuracy: accuracy)
        XCTAssertEqual(try UnitNormalizer.tesla(from: 9.4, unit: nil), 9.4, accuracy: accuracy)
    }

    func testTeslaUnrecognizedUnitThrows() {
        XCTAssertThrowsError(try UnitNormalizer.tesla(from: 1.0, unit: .unrecognized)) { error in
            guard case UnitNormalizationError.unrecognizedUnit(let dimension) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(dimension, "magnetic field strength")
        }
    }
}
