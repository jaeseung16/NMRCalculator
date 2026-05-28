//
//  NMRAssistantMessage.swift
//  NMRCalculator2
//

import Foundation

struct NMRAssistantMessage: Identifiable, Sendable {
    enum Role: Sendable {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    let text: String
}
