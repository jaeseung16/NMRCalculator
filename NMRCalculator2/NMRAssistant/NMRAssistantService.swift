//
//  NMRAssistantService.swift
//  NMRCalculator2
//

import Foundation
import FoundationModels
import Observation
import os

@MainActor
@Observable
final class NMRAssistantService {
    private static let logger = Logger()
    
    private let navigationState: NMRAssistantNavigationState
    private var session: LanguageModelSession?
    var messages: [NMRAssistantMessage] = []
    var isProcessing = false
    var modelUnavailableReason: String?

    /// Number of user questions after which the assistant suggests an off-ramp
    /// (opening a detail view or starting a new conversation) to keep the
    /// on-device context window from overflowing.
    private static let maxQuestions = 4

    /// Count of user questions in the current conversation.
    private var userQuestionCount: Int {
        messages.lazy.filter { $0.role == .user }.count
    }

    static let instructions = """
            You are an NMR facility manager. Answer questions about NMR parameters. \
            You only help with NMR (nuclear magnetic resonance) topics: nuclei, NMR \
            parameters, pulses, and the related physics. If a question is not about NMR, \
            do not answer it — instead, politely say you can only help with NMR-related \
            questions and invite the user to ask one. \
            For numerical results in the answers, use the provided tools.
            Follow these instructions to collect the information from the provided tools: \
            1. Normalize nucleus identifiers before passing them to the tools `calculate_larmor_frequency` and `open_nucleus_detail`. You may use the 'list_nuclei' tool to find the normalized identifier. You may use the `calculate_pulse_amplitude` tool without passing the normalized identifier. If you are not sure which nucleus to use, please ask the user for clarification. \
              Examples:
                a. Normalized: 13C, unnormalized: Carbon 13, Carbon-13
                b. Normalized: 3He, unnormalized: Helium 3, Helium-3
                c. Normalized: 1H, unnormalized: Proton
                d. Normalized: 2H, unnormalized: Deuterium, D
                e. Normalized: 3H, unnormalized: Tritium, T
            2. Pass each numerical value with the unit the user stated; do not convert units. Do not set any numerical parameter the user didn't provide. For each calculation tool, set the 'calculate' field (or 'given' for calculate_larmor_frequency) to name the parameter the user wants computed, then supply the other inputs with their values and units. If any required input is missing, ask the user.
            """

    static func makeTools(navigationState: NMRAssistantNavigationState) -> [any Tool] {
        [
            ErnstAngleTool(),
            FrequencyDomainTool(),
            TimeDomainTool(),
            PulseRelativePowerTool(),
            LarmorFrequencyTool(),
            PulseAmplitudeTool(),
            NucleusListTool(),
            OpenNucleusDetailTool(navigationState: navigationState)
        ]
    }

    init(navigationState: NMRAssistantNavigationState) {
        self.navigationState = navigationState
        configureSession()
    }

    /// Clears the conversation and starts a fresh session, freeing the
    /// accumulated transcript so the context window resets.
    func reset() {
        guard !isProcessing else { return }
        messages.removeAll()
        configureSession()
    }

    private func configureSession() {
        switch SystemLanguageModel.default.availability {
        case .available:
            session = LanguageModelSession(
                tools: Self.makeTools(navigationState: navigationState),
                instructions: Self.instructions
            )
            modelUnavailableReason = nil
            Self.logTokenCount(for: Self.instructions)
        case .unavailable(let reason):
            session = nil
            switch reason {
            case .deviceNotEligible:
                modelUnavailableReason = "Apple Intelligence is not supported on this device."
            case .appleIntelligenceNotEnabled:
                modelUnavailableReason = "Apple Intelligence is not enabled. Go to Settings → Apple Intelligence & Siri to enable it."
            case .modelNotReady:
                modelUnavailableReason = "The language model is not ready yet. Please wait for Apple Intelligence to finish downloading."
            @unknown default:
                modelUnavailableReason = "The language model is unavailable."
            }
        @unknown default:
            session = nil
            modelUnavailableReason = "The language model is unavailable."
        }
    }

    func send(_ text: String) async {
        guard !isProcessing else { return }
        guard let session else {
            messages.append(
                NMRAssistantMessage(id: UUID(),
                                    role: .assistant,
                                    text: modelUnavailableReason ?? "The language model is unavailable."
                                   )
            )
            return
        }
        Self.logger.info("User message: \(text, privacy: .public)")
        messages.append(NMRAssistantMessage(id: UUID(), role: .user, text: text))
        isProcessing = true
        defer { isProcessing = false }
        do {
            let response = try await session.respond(to: text)
            Self.logger.info("Assistant response: \(response.content, privacy: .public)")
            messages.append(NMRAssistantMessage(id: UUID(), role: .assistant, text: response.content))
            appendOffRampSuggestionIfNeeded()
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            messages.append(
                NMRAssistantMessage(id: UUID(),
                                    role: .assistant,
                                    text: "Exceeded context window size. Please restart the assistant."
                                   )
            )
        } catch {
            messages.append(
                NMRAssistantMessage(id: UUID(), role: .assistant, text: "Encountered an error. Please restart the assistant.")
            )
            if let error = error as? LanguageModelSession.GenerationError {
                Self.logger.error("failureReason: \(error.failureReason ?? ""), errorDescription: \(error.errorDescription ?? ""), recoverySuggestion: \(error.recoverySuggestion ?? "")")
            }
        }
        
        /*
        session.transcript.forEach {
            switch $0 {
            case .instructions(let instructions):
                Self.logger.info("Instructions: \(instructions)")
            case .prompt(let prompt):
                Self.logger.info("Prompt: \(prompt)")
            case .toolCalls(let call):
                Self.logger.info("ToolCall: \(call)")
            case .toolOutput(let output):
                Self.logger.info("ToolOutput: \(output)")
            case .response(let response):
                Self.logger.info("Response: \(response)")
            @unknown default:
                Self.logger.info("unknown: \($0)")
            }
        }
         */
    }
    
    /// Once the user has asked `maxQuestions`, gently suggest an off-ramp so
    /// the on-device context window doesn't overflow mid-answer. Fires exactly
    /// once (at the threshold); the user is free to keep asking afterwards.
    private func appendOffRampSuggestionIfNeeded() {
        guard userQuestionCount == Self.maxQuestions else { return }
        messages.append(
            NMRAssistantMessage(
                id: UUID(),
                role: .assistant,
                text: "We've covered several questions. To keep responses fast and accurate, you can open a nucleus's detail view for more, or start a new conversation. You're welcome to keep asking, too."
            )
        )
    }

    static func logTokenCount(for instructions: String) -> Void {
        Task {
            do {
                if #available(iOS 26.4, *) {
                    let tokenCount = try await SystemLanguageModel.default.tokenCount(for: instructions)
                    Self.logger.info("Counted \(tokenCount) tokens for \(instructions)")
                } else {
                    // Fallback on earlier versions
                    Self.logger.info("Failed to count tokens for \(instructions): not available on this device")
                }
            } catch {
                Self.logger.error("Failed to count tokens for \(instructions): \(error)")
            }
        }
    }
}
