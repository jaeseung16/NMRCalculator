//
//  LarmorFrequencyTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct LarmorFrequencyTool: Tool {
    let name = "calculate_larmor_frequency"
    let description = "Calculates Larmor frequency, magnetic field, or proton frequency for a nucleus. Provide one input."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C', '31P'")
        var nucleusIdentifier: String
        @Guide(description: "External magnetic field in Tesla; omit if providing a frequency")
        var magneticFieldInTesla: Double?
        @Guide(description: "Larmor frequency of the nucleus in MHz; omit if providing another input")
        var larmorFrequencyInMHz: Double?
        @Guide(description: "Proton (1H) NMR frequency in MHz; omit if providing another input")
        var protonFrequencyInMHz: Double?
        @Guide(description: "Free electron Larmor frequency in GHz; omit if providing another input")
        var electronFrequencyInGHz: Double?
    }

    func call(arguments: Arguments) async throws -> String {
        guard let nucleus = await MainActor.run(body: {
            NMRPeriodicTable.shared.nucleus(matching: arguments.nucleusIdentifier)
        }) else {
            return "Nucleus '\(arguments.nucleusIdentifier)' not found. Use list_nuclei to find valid identifiers."
        }
        let request = LarmorFrequencyRequest(
            nucleus: nucleus,
            magneticField: arguments.magneticFieldInTesla,
            larmorFrequency: arguments.larmorFrequencyInMHz,
            protonFrequency: arguments.protonFrequencyInMHz,
            electronFrequency: arguments.electronFrequencyInGHz
        )
        switch NMRCalcFactory.shared.create(.larmor).process(request) {
        case .success(let r):
            guard let r = r as? LarmorFrequencyResponse else { throw NMRCalcError.invalidOutput }
            return "\(nucleus.identifier) Larmor frequency: \(String(format: "%.4f", r.larmorFrequency)) MHz, B0: \(String(format: "%.4f", r.magneticField)) T, Proton frequency: \(String(format: "%.4f", r.protonFrequency)) MHz"
        case .failure(let error):
            throw error
        }
    }
}
