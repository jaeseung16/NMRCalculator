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
        let query = arguments.elementNameOrSymbol.lowercased()
        let matches = await MainActor.run {
            NMRPeriodicTable.shared.nuclei.filter {
                $0.nameNucleus.lowercased() == query || $0.symbolNucleus.lowercased() == query
            }
        }
        guard !matches.isEmpty else {
            return "No NMR-active isotopes found for '\(arguments.elementNameOrSymbol)'."
        }
        let lines = matches.map { n in
            "\(n.identifier): spin \(n.nuclearSpin), γ = \(String(format: "%.4f", abs(n.γ))) MHz/T, abundance \(n.naturalAbundance)%"
        }
        return lines.joined(separator: "\n")
    }
}
