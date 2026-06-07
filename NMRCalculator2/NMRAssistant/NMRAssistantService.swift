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
    
    private var session: LanguageModelSession?
    var messages: [NMRAssistantMessage] = []
    var isProcessing = false
    var modelUnavailableReason: String?

    init(navigationState: NMRAssistantNavigationState) {
        switch SystemLanguageModel.default.availability {
        case .available:
            let instructions = """
                    You are an NMR calculator assistant. \
                    Use the provided tools to answer questions about NMR parameters. \
                    Always include the numeric result and its unit in your reply.
                    """
            session = LanguageModelSession(
                tools: [
                    ErnstAngleTool(),
                    FrequencyDomainTool(),
                    TimeDomainTool(),
                    PulseRelativePowerTool(),
                    LarmorFrequencyTool(),
                    PulseAmplitudeTool(),
                    NucleusListTool(),
                    OpenNucleusDetailTool(navigationState: navigationState)
                ],
                instructions: instructions
            )
            modelUnavailableReason = nil
            Self.logTokenCount(for: instructions)
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
        messages.append(NMRAssistantMessage(id: UUID(), role: .user, text: text))
        isProcessing = true
        defer { isProcessing = false }
        do {
            let response = try await session.respond(to: text)
            messages.append(NMRAssistantMessage(id: UUID(), role: .assistant, text: response.content))
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            messages.append(
                NMRAssistantMessage(id: UUID(),
                                    role: .assistant,
                                    text: "Error: Exceeded context window size. Please restart the assistant."
                                   )
            )
        } catch {
            messages.append(
                NMRAssistantMessage(id: UUID(), role: .assistant, text: "Error: \(error.localizedDescription)")
            )
            if let error = error as? LanguageModelSession.GenerationError {
                Self.logger.error("failureReason: \(error.failureReason ?? ""), errorDescription: \(error.errorDescription ?? ""), recoverySuggestion: \(error.recoverySuggestion ?? "")")
            }
        }
        
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
    }
    
    static func logTokenCount(for instructions: String) -> Void {
        Task {
            do {
                if #available(iOS 26.4, *) {
                    let tokenCount = try await SystemLanguageModel.default.tokenCount(for: instructions)
                    Self.logger.info("Counted tokens for \(instructions): count=\(tokenCount)")
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
