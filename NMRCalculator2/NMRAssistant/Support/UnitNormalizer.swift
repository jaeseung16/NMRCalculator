//
//  UnitNormalizer.swift
//  NMRCalculator2
//

import Foundation
import FoundationModels

enum UnitNormalizationError: Error {
    case unrecognizedUnit(dimension: String)
}

@Generable
enum TimeUnit: String, CaseIterable {
    case seconds
    case milliseconds
    case microseconds
    case nanoseconds
    case minutes
    case unrecognized

    var secondsPerUnit: Double? {
        switch self {
        case .seconds: return 1.0
        case .milliseconds: return 1.0e-3
        case .microseconds: return 1.0e-6
        case .nanoseconds: return 1.0e-9
        case .minutes: return 60.0
        case .unrecognized: return nil
        }
    }
}

@Generable
enum AngleUnit: String, CaseIterable {
    case degrees
    case radians
    case unrecognized

    var degreesPerUnit: Double? {
        switch self {
        case .degrees: return 1.0
        case .radians: return 180.0 / Double.pi
        case .unrecognized: return nil
        }
    }
}

@Generable
enum FrequencyUnit: String, CaseIterable {
    case hertz
    case kilohertz
    case megahertz
    case gigahertz
    case unrecognized

    var hertzPerUnit: Double? {
        switch self {
        case .hertz: return 1.0
        case .kilohertz: return 1.0e3
        case .megahertz: return 1.0e6
        case .gigahertz: return 1.0e9
        case .unrecognized: return nil
        }
    }
}

@Generable
enum MagneticFieldUnit: String, CaseIterable {
    case tesla
    case millitesla
    case microtesla
    case gauss
    case unrecognized

    var teslaPerUnit: Double? {
        switch self {
        case .tesla: return 1.0
        case .millitesla: return 1.0e-3
        case .microtesla: return 1.0e-6
        case .gauss: return 1.0e-4
        case .unrecognized: return nil
        }
    }
}

/// Converts user-stated quantities to the canonical units the calculators expect.
/// The tools declare their unit arguments as the `@Generable` enums above, so the
/// model selects a unit by constrained decoding while generating the tool call —
/// free-form unit strings proved unreliable (the model abbreviated "microsecond"
/// as "ms"). A nil unit is taken as the `assuming` unit of the calling tool's
/// parameter; `unrecognized` means the user's spelling was not a unit of the
/// dimension at all. All numeric conversion is done in Swift.
struct UnitNormalizer {
    static func seconds(from value: Double, unit: TimeUnit?, assuming defaultUnit: TimeUnit = .seconds) throws -> Double {
        guard let secondsPerUnit = (unit ?? defaultUnit).secondsPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(dimension: "time")
        }
        return value * secondsPerUnit
    }

    static func degrees(from value: Double, unit: AngleUnit?, assuming defaultUnit: AngleUnit = .degrees) throws -> Double {
        guard let degreesPerUnit = (unit ?? defaultUnit).degreesPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(dimension: "angle")
        }
        return value * degreesPerUnit
    }

    static func hertz(from value: Double, unit: FrequencyUnit?, assuming defaultUnit: FrequencyUnit = .hertz) throws -> Double {
        guard let hertzPerUnit = (unit ?? defaultUnit).hertzPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(dimension: "frequency")
        }
        return value * hertzPerUnit
    }

    static func tesla(from value: Double, unit: MagneticFieldUnit?, assuming defaultUnit: MagneticFieldUnit = .tesla) throws -> Double {
        guard let teslaPerUnit = (unit ?? defaultUnit).teslaPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(dimension: "magnetic field strength")
        }
        return value * teslaPerUnit
    }
}
