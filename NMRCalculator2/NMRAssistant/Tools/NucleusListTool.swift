//
//  NucleusListTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct NucleusListTool: Tool {
    let name = "list_nuclei"
    let description = "Lists NMR-active isotopes for a given element name or symbol."

    @Generable
    struct Arguments {
        @Guide(description: "Element name (e.g. 'Carbon') or symbol (e.g. 'C')")
        var elementNameOrSymbol: String
    }

    func call(arguments: Arguments) async throws -> String {
        let normalized = await MainActor.run {
            NMRPeriodicTable.shared.normalizedElementKey(for: arguments.elementNameOrSymbol)
        }
        let matches = await MainActor.run {
            NMRPeriodicTable.shared.nucleiByElement[normalized]
        }
        guard let matches = matches, !matches.isEmpty else {
            return "No NMR-active isotopes found for '\(arguments.elementNameOrSymbol)'."
        }
        let lines = matches.map { n in
            "\(n.identifier): spin \(n.nuclearSpin), γ = \(String(format: "%.4f", abs(n.γ))) MHz/T, abundance \(n.naturalAbundance)%"
        }
        return lines.joined(separator: "\n")
    }
}
