//
//  LarmorFrequencyTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

@Generable
enum LarmorFrequencyGiven {
    case magneticField
    case larmorFrequency
    case protonFrequency
    case electronFrequency
}

struct LarmorFrequencyTool: Tool {
    private static let logger = Logger()

    let name = "calculate_larmor_frequency"
    let description = "Calculates Larmor frequency, magnetic field, and proton frequency for a nucleus. Set 'given' to the one parameter the user provided, then supply its value and unit."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C', '31P'")
        var nucleusIdentifier: String
        @Guide(description: "Which input the user provided")
        var given: LarmorFrequencyGiven
        @Guide(description: "External magnetic field")
        var magneticField: Double?
        @Guide(description: "Unit of the magnetic field; omit if not stated")
        var magneticFieldUnit: MagneticFieldUnit?
        @Guide(description: "Larmor frequency of the nucleus")
        var larmorFrequency: Double?
        @Guide(description: "Unit of the Larmor frequency; omit if not stated")
        var larmorFrequencyUnit: FrequencyUnit?
        @Guide(description: "Proton (1H) NMR frequency")
        var protonFrequency: Double?
        @Guide(description: "Unit of the proton frequency; omit if not stated")
        var protonFrequencyUnit: FrequencyUnit?
        @Guide(description: "Free electron Larmor frequency")
        var electronFrequency: Double?
        @Guide(description: "Unit of the electron frequency; omit if not stated")
        var electronFrequencyUnit: FrequencyUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        guard let nucleus = await MainActor.run(body: {
            NMRPeriodicTable.shared.nucleus(matching: arguments.nucleusIdentifier)
        }) else {
            return "Nucleus '\(arguments.nucleusIdentifier)' not found. Use list_nuclei to find valid identifiers."
        }

        let magneticField = arguments.magneticField.flatMap { $0 == 0.0 ? nil : $0 }
        let larmorFrequency = arguments.larmorFrequency.flatMap { $0 == 0.0 ? nil : $0 }
        let protonFrequency = arguments.protonFrequency.flatMap { $0 == 0.0 ? nil : $0 }
        let electronFrequency = arguments.electronFrequency.flatMap { $0 == 0.0 ? nil : $0 }

        let magneticFieldInTesla: Double?
        let larmorFrequencyInMHz: Double?
        let protonFrequencyInMHz: Double?
        let electronFrequencyInGHz: Double?
        do {
            magneticFieldInTesla = try Self.tesla(magneticField, unit: arguments.magneticFieldUnit)
            larmorFrequencyInMHz = try Self.megahertz(larmorFrequency, unit: arguments.larmorFrequencyUnit, assuming: .megahertz)
            protonFrequencyInMHz = try Self.megahertz(protonFrequency, unit: arguments.protonFrequencyUnit, assuming: .megahertz)
            electronFrequencyInGHz = try Self.gigahertz(electronFrequency, unit: arguments.electronFrequencyUnit, assuming: .gigahertz)
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
        }

        let given: ToolResponseEvaluator.LarmorFrequencyGivenParameter
        let request: LarmorFrequencyRequest

        switch arguments.given {
        case .magneticField:
            guard let field = magneticFieldInTesla, field > 0 else {
                return "Magnetic field is required. Provide a positive value with its unit."
            }
            given = .magneticField
            request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: field, larmorFrequency: nil, protonFrequency: nil, electronFrequency: nil)

        case .larmorFrequency:
            guard let larmor = larmorFrequencyInMHz, larmor > 0 else {
                return "Larmor frequency is required. Provide a positive value with its unit."
            }
            given = .larmorFrequency
            request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: nil, larmorFrequency: larmor, protonFrequency: nil, electronFrequency: nil)

        case .protonFrequency:
            guard let proton = protonFrequencyInMHz, proton > 0 else {
                return "Proton frequency is required. Provide a positive value with its unit."
            }
            given = .protonFrequency
            request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: nil, larmorFrequency: nil, protonFrequency: proton, electronFrequency: nil)

        case .electronFrequency:
            guard let electron = electronFrequencyInGHz, electron > 0 else {
                return "Electron frequency is required. Provide a positive value with its unit."
            }
            given = .electronFrequency
            request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: nil, larmorFrequency: nil, protonFrequency: nil, electronFrequency: electron)
        }

        switch NMRCalcFactory.shared.create(.larmor).process(request) {
        case .success(let response):
            guard let response = response as? LarmorFrequencyResponse else { throw NMRCalcError.invalidOutput }
            guard ToolResponseEvaluator.verify(response, given: given) else {
                Self.logger.error("Round-trip verification failed for \(String(describing: response))")
                throw NMRCalcError.invalidOutput
            }
            return Self.format(response, given: given)
        case .failure(let error):
            Self.logger.error("Failed to process \(String(describing: request)): \(error.localizedDescription)")
            throw error
        }
    }

    private static func tesla(_ value: Double?, unit: MagneticFieldUnit?) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.tesla(from: value, unit: unit, assuming: .tesla)
    }

    private static func megahertz(_ value: Double?, unit: FrequencyUnit?, assuming defaultUnit: FrequencyUnit) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.hertz(from: value, unit: unit, assuming: defaultUnit) / 1.0e6
    }

    private static func gigahertz(_ value: Double?, unit: FrequencyUnit?, assuming defaultUnit: FrequencyUnit) throws -> Double? {
        guard let value else { return nil }
        return try UnitNormalizer.hertz(from: value, unit: unit, assuming: defaultUnit) / 1.0e9
    }

    private static func format(_ response: LarmorFrequencyResponse, given: ToolResponseEvaluator.LarmorFrequencyGivenParameter) -> String {
        let field = "magnetic field B0 = \(String(format: "%.4f", response.magneticField)) T"
        let larmor = "\(response.nucleus.identifier) Larmor frequency = \(String(format: "%.4f", response.larmorFrequency)) MHz"
        let proton = "proton frequency = \(String(format: "%.4f", response.protonFrequency)) MHz"
        let electron = "free electron frequency = \(String(format: "%.4f", response.electronFrequency)) GHz"
        switch given {
        case .magneticField:
            return "Calculated \(larmor), \(proton) (given \(field))"
        case .larmorFrequency:
            return "Calculated \(field), \(proton) (given \(larmor))"
        case .protonFrequency:
            return "Calculated \(larmor), \(field) (given \(proton))"
        case .electronFrequency:
            return "Calculated \(larmor), \(field), \(proton) (given \(electron))"
        }
    }
}
