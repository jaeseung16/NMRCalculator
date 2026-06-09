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
                    You are an NMR facility manager. Answer questions about NMR parameters. \
                    For numerical results in the answers, use the provided tools.
                    Follow these instructions to collect the information from the provided tools: \
                    1. Normalize nucleus identifiers before passing them to the tools `calculate_larmor_frequency` and `open_nucleus_detail`. You may use the 'list_nuclei' tool to find the normalized identifier. You may use the `calculate_pulse_amplitude` tool without passing the normalized identifier. If you are not sure which nucleus to use, please ask the user for clarification. \
                      Examples:
                        a. Normalized: 13C, unnormalized: Carbon 13, Carbon-13
                        b. Normalized: 3He, unnormalized: Helium 3, Helium-3
                        c. Normalized: 1H, unnormalized: Proton, P
                        d. Normalized: 2H, unnormalized: Deuterium, D
                        e. Normalized: 3H, unnormalized: Tritium, T
                    2. Apply unit conversions before using the tools below. \
                      a. `calculate_larmor_frequency`: Convert magnetic field strength to Tesla, NMR frequencies to MHz, and free electron Larmor frequency to GHz. \
                      b. `calculate_pulse_amplitude`: Convert pulse duration to microseconds, flip angle to degrees, and RF amplitude to kilohertz. \
                      c. `calculate_pulse_relative_power`: Convert pulse duration to microseconds and flip angle to degrees. \
                      d. `calculate_time_domain`: Convert dwell time to microseconds and acquisition time to sec. \
                      e. `calculate_frequency_domain`: Convert spectral width to kilohertz and frequency resolution to Hertz. \
                      f. `calculate_ernst_angle`: Convert T1 relaxation time to seconds, repetition time to seconds, and Ernst angle to degrees. \
                    3. When using the tools `calculate_ernst_angle`, `calculate_frequency_domain`, `calculate_time_domain`, `calculate_larmor_frequency`, `calculate_pulse_amplitude`, pass nil to the paramter you are calculating from the other parameters, which should not be nil. If some of the other paramters are nil, please ask the user for clarification.
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
