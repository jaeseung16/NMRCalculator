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
    let description = "Calculates Larmor frequency, magnetic field, and proton frequency for a nucleus. Set 'given' to the one parameter the user provided, then put its number in 'value' and its unit in the matching unit field."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C', '31P'")
        var nucleusIdentifier: String
        @Guide(description: "Which input the user provided")
        var given: LarmorFrequencyGiven
        @Guide(description: "The numeric value of the input named by 'given'")
        var value: Double
        @Guide(description: "Unit of the value when 'given' is magneticField; omit if not stated")
        var magneticFieldUnit: MagneticFieldUnit?
        @Guide(description: "Unit of the value when 'given' is larmorFrequency, protonFrequency, or electronFrequency; omit if not stated")
        var frequencyUnit: FrequencyUnit?
    }

    func call(arguments: Arguments) async throws -> String {
        Self.logger.info("\(name): \(String(describing: arguments), privacy: .public)")
        guard let nucleus = await MainActor.run(body: {
            NMRPeriodicTable.shared.nucleus(matching: arguments.nucleusIdentifier)
        }) else {
            return "Nucleus '\(arguments.nucleusIdentifier)' not found. Use list_nuclei to find valid identifiers."
        }

        // The model fills a single `value` field disambiguated by `given`, which
        // avoids the misrouting seen when each parameter had its own value field.
        let value = arguments.value == 0.0 ? nil : arguments.value

        let given: ToolResponseEvaluator.LarmorFrequencyGivenParameter
        let request: LarmorFrequencyRequest

        do {
            switch arguments.given {
            case .magneticField:
                guard let field = try Self.tesla(value, unit: arguments.magneticFieldUnit), field > 0 else {
                    return "Magnetic field is required. Provide a positive value with its unit."
                }
                given = .magneticField
                request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: field, larmorFrequency: nil, protonFrequency: nil, electronFrequency: nil)

            case .larmorFrequency:
                guard let larmor = try Self.megahertz(value, unit: arguments.frequencyUnit, assuming: .megahertz), larmor > 0 else {
                    return "Larmor frequency is required. Provide a positive value with its unit."
                }
                given = .larmorFrequency
                request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: nil, larmorFrequency: larmor, protonFrequency: nil, electronFrequency: nil)

            case .protonFrequency:
                guard let proton = try Self.megahertz(value, unit: arguments.frequencyUnit, assuming: .megahertz), proton > 0 else {
                    return "Proton frequency is required. Provide a positive value with its unit."
                }
                given = .protonFrequency
                request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: nil, larmorFrequency: nil, protonFrequency: proton, electronFrequency: nil)

            case .electronFrequency:
                guard let electron = try Self.gigahertz(value, unit: arguments.frequencyUnit, assuming: .gigahertz), electron > 0 else {
                    return "Electron frequency is required. Provide a positive value with its unit."
                }
                given = .electronFrequency
                request = LarmorFrequencyRequest(nucleus: nucleus, magneticField: nil, larmorFrequency: nil, protonFrequency: nil, electronFrequency: electron)
            }
        } catch UnitNormalizationError.unrecognizedUnit(let dimension) {
            return "A unit was not recognized as a valid \(dimension) unit. Ask the user to restate the value with a standard unit."
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
