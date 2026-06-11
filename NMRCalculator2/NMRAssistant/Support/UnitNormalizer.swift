//
//  UnitNormalizer.swift
//  NMRCalculator2
//

import Foundation
import FoundationModels
import os

enum UnitNormalizationError: Error {
    case unrecognizedUnit(String)
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
/// Unit spellings are resolved with a lookup table first; a dedicated
/// `LanguageModelSession` classifies the spelling (guided generation onto a unit
/// enum) only when the table misses. All numeric conversion is done in Swift —
/// no numbers pass through the model. A nil or blank unit is taken as the
/// `assuming` unit of the calling tool's parameter.
struct UnitNormalizer {
    private static let logger = Logger()

    private static let timeUnits: [String: TimeUnit] = [
        "s": .seconds, "sec": .seconds, "secs": .seconds, "second": .seconds, "seconds": .seconds,
        "ms": .milliseconds, "msec": .milliseconds, "msecs": .milliseconds,
        "millisecond": .milliseconds, "milliseconds": .milliseconds,
        "us": .microseconds, "usec": .microseconds, "usecs": .microseconds,
        "µs": .microseconds, "µsec": .microseconds, "μs": .microseconds, "μsec": .microseconds,
        "microsecond": .microseconds, "microseconds": .microseconds,
        "ns": .nanoseconds, "nsec": .nanoseconds, "nsecs": .nanoseconds,
        "nanosecond": .nanoseconds, "nanoseconds": .nanoseconds,
        "min": .minutes, "mins": .minutes, "minute": .minutes, "minutes": .minutes
    ]

    private static let angleUnits: [String: AngleUnit] = [
        "deg": .degrees, "degs": .degrees, "degree": .degrees, "degrees": .degrees, "°": .degrees,
        "rad": .radians, "rads": .radians, "radian": .radians, "radians": .radians
    ]

    private static let frequencyUnits: [String: FrequencyUnit] = [
        "hz": .hertz, "hertz": .hertz,
        "khz": .kilohertz, "kilohertz": .kilohertz,
        "mhz": .megahertz, "megahertz": .megahertz,
        "ghz": .gigahertz, "gigahertz": .gigahertz
    ]

    private static let magneticFieldUnits: [String: MagneticFieldUnit] = [
        "t": .tesla, "tesla": .tesla, "teslas": .tesla,
        "mt": .millitesla, "millitesla": .millitesla, "milliteslas": .millitesla,
        "ut": .microtesla, "µt": .microtesla, "μt": .microtesla,
        "microtesla": .microtesla, "microteslas": .microtesla,
        "g": .gauss, "gauss": .gauss
    ]

    static func seconds(from value: Double, unit: String?, assuming defaultUnit: TimeUnit = .seconds) async throws -> Double {
        guard let key = normalizedKey(unit) else { return value * (defaultUnit.secondsPerUnit ?? 1.0) }
        let timeUnit: TimeUnit
        if let match = timeUnits[key] {
            timeUnit = match
        } else {
            timeUnit = try await classify(key, as: TimeUnit.self, dimension: "time")
        }
        guard let secondsPerUnit = timeUnit.secondsPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(key)
        }
        return value * secondsPerUnit
    }

    static func degrees(from value: Double, unit: String?, assuming defaultUnit: AngleUnit = .degrees) async throws -> Double {
        guard let key = normalizedKey(unit) else { return value * (defaultUnit.degreesPerUnit ?? 1.0) }
        let angleUnit: AngleUnit
        if let match = angleUnits[key] {
            angleUnit = match
        } else {
            angleUnit = try await classify(key, as: AngleUnit.self, dimension: "angle")
        }
        guard let degreesPerUnit = angleUnit.degreesPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(key)
        }
        return value * degreesPerUnit
    }

    static func hertz(from value: Double, unit: String?, assuming defaultUnit: FrequencyUnit = .hertz) async throws -> Double {
        guard let key = normalizedKey(unit) else { return value * (defaultUnit.hertzPerUnit ?? 1.0) }
        let frequencyUnit: FrequencyUnit
        if let match = frequencyUnits[key] {
            frequencyUnit = match
        } else {
            frequencyUnit = try await classify(key, as: FrequencyUnit.self, dimension: "frequency")
        }
        guard let hertzPerUnit = frequencyUnit.hertzPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(key)
        }
        return value * hertzPerUnit
    }

    static func tesla(from value: Double, unit: String?, assuming defaultUnit: MagneticFieldUnit = .tesla) async throws -> Double {
        guard let key = normalizedKey(unit) else { return value * (defaultUnit.teslaPerUnit ?? 1.0) }
        let fieldUnit: MagneticFieldUnit
        if let match = magneticFieldUnits[key] {
            fieldUnit = match
        } else {
            fieldUnit = try await classify(key, as: MagneticFieldUnit.self, dimension: "magnetic field strength")
        }
        guard let teslaPerUnit = fieldUnit.teslaPerUnit else {
            throw UnitNormalizationError.unrecognizedUnit(key)
        }
        return value * teslaPerUnit
    }

    private static func normalizedKey(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return key.isEmpty ? nil : key
    }

    private static func classify<U: Generable>(_ unit: String, as type: U.Type, dimension: String) async throws -> U {
        let session = LanguageModelSession(
            instructions: "Identify the unit of \(dimension) named by the user. Choose 'unrecognized' if the input is not a unit of \(dimension)."
        )
        let response = try await session.respond(to: unit, generating: U.self)
        Self.logger.info("Classified unit '\(unit)' as \(String(describing: response.content))")
        return response.content
    }
}
