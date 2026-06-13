//
//  LarmorFrequencyTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon
import os

struct LarmorFrequencyTool: Tool {
    private static let logger = Logger()

    let name = "calculate_larmor_frequency"
    let description = "Calculates Larmor frequency, magnetic field, or proton frequency for a nucleus. Provide exactly one input with the unit the user stated."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C', '31P'")
        var nucleusIdentifier: String
        @Guide(description: "External magnetic field; omit if providing a frequency")
        var magneticField: Double?
        @Guide(description: "Unit of the magnetic field; omit if not stated")
        var magneticFieldUnit: MagneticFieldUnit?
        @Guide(description: "Larmor frequency of the nucleus; omit if providing another input")
        var larmorFrequency: Double?
        @Guide(description: "Unit of the Larmor frequency; omit if not stated")
        var larmorFrequencyUnit: FrequencyUnit?
        @Guide(description: "Proton (1H) NMR frequency; omit if providing another input")
        var protonFrequency: Double?
        @Guide(description: "Unit of the proton frequency; omit if not stated")
        var protonFrequencyUnit: FrequencyUnit?
        @Guide(description: "Free electron Larmor frequency; omit if providing another input")
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

        let providedCount = [magneticField != nil,
                             larmorFrequency != nil,
                             protonFrequency != nil,
                             electronFrequency != nil].filter { $0 }.count
        guard providedCount == 1 else {
            return "Provide exactly one of: magnetic field, Larmor frequency, proton frequency, free electron frequency."
        }

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

        if let providedValue = magneticFieldInTesla ?? larmorFrequencyInMHz ?? protonFrequencyInMHz ?? electronFrequencyInGHz,
           providedValue <= 0 {
            return "Invalid input \(providedValue): it must be positive. Pass the user's stated value; never pass 0 as a placeholder."
        }

        let given: ToolResponseEvaluator.LarmorFrequencyGivenParameter
        if magneticFieldInTesla != nil {
            given = .magneticField
        } else if larmorFrequencyInMHz != nil {
            given = .larmorFrequency
        } else if protonFrequencyInMHz != nil {
            given = .protonFrequency
        } else {
            given = .electronFrequency
        }

        let request = LarmorFrequencyRequest(
            nucleus: nucleus,
            magneticField: magneticFieldInTesla,
            larmorFrequency: larmorFrequencyInMHz,
            protonFrequency: protonFrequencyInMHz,
            electronFrequency: electronFrequencyInGHz
        )
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
