//
//  OpenNucleusDetailTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct OpenNucleusDetailTool: Tool {
    let name = "open_nucleus_detail"
    let description = "Opens the detail view for a specific NMR isotope."

    @Generable
    struct Arguments {
        @Guide(description: "Nucleus identifier, e.g. '1H', '13C'")
        var nucleusIdentifier: String
    }

    private let navigationState: NMRAssistantNavigationState

    init(navigationState: NMRAssistantNavigationState) {
        self.navigationState = navigationState
    }

    func call(arguments: Arguments) async throws -> String {
        return await MainActor.run {
            guard NMRPeriodicTable.shared.nucleiById[arguments.nucleusIdentifier] != nil else {
                return "Nucleus '\(arguments.nucleusIdentifier)' not found. Use list_nuclei to find valid identifiers."
            }
            navigationState.requestedNucleusID = arguments.nucleusIdentifier
            return "Opening detail view for \(arguments.nucleusIdentifier)."
        }
    }
}
