//
//  NMRAssistantNavigationState.swift
//  NMRCalculator2
//

import Observation
import NMRCalculatorCommon

@MainActor
@Observable
final class NMRAssistantNavigationState {
    var requestedNucleusID: NMRNucleus.ID?
}
