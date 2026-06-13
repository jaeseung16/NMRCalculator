//
//  NMRCalculator2Tests.swift
//  NMRCalculator2Tests
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import XCTest
import FoundationModels
@testable import NMRCalculator2

final class NMRCalculator2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Availability can report `.available` while generation still fails in
    /// this environment (e.g. a simulator without usable host model assets),
    /// so probe an actual response before running model-dependent tests.
    private func skipUnlessModelResponds() async throws {
        guard case .available = SystemLanguageModel.default.availability else {
            throw XCTSkip("The language model is unavailable")
        }
        do {
            _ = try await LanguageModelSession().respond(to: "Reply with the word ready.")
        } catch {
            throw XCTSkip("The language model cannot generate in this environment: \(error)")
        }
    }

    @MainActor
    func testNMRAssistantService() async throws {
        try await skipUnlessModelResponds()
        let navigationState = NMRAssistantNavigationState()
        let service = NMRAssistantService(navigationState: navigationState)

        await service.send("Which isotopes of carbon are NMR active?")

        /*
         Questions:
         Which isotopes of Carbon are NMR active?
         Which isotopes of Hydrogen are NMR active?
         Which isotopes of N are NMR active?
         What is the resonance frequency of C-13 when the proton NMR frequency is 600 MHz?
         What is the magnetic field when N-15 NMR frequency is 100 MHz?
         What is the gyromagnetic ratio of N-15?
         What is the NMR frequency of N15 at 24T?
         What is the gyromagnetic ratio of sodium nuclei?
         What is the NMR frequency of sodium when the proton frequency is 500 MHz?
         What is the magnetic field when the sodium NMR frequency is 100 MHz?
         What would be the spectral widht when the number of data points is 1024 and the frequency resolution is 1 HZ?
         What is the duration of a 90-degree pulse when the RF ampliotude is 1 kHz?
         What it the duration of a 10-microsecond 90-deg pulse?
         What is the RF amplitude of 10-microsecond 90-deg pulse?
         */

        print("**********")
        service.messages.forEach { print($0) }
        print("**********")
        //XCTAssertTrue(service.messages.isEmpty)
    }

    /// Unit-bearing phrasings from the question list: each question states a
    /// value with an explicit unit that the tools (not the model) must convert.
    /// One session per question so a long transcript cannot exceed the context
    /// window. Skipped when the on-device model is unavailable.
    @MainActor
    func testNMRAssistantServiceUnitBearingPhrasings() async throws {
        try await skipUnlessModelResponds()
        let questions = [
            "What is the Ernst angle when T1 is 1500 ms and the repetition time is 1 s?",
            "What is the resonance frequency of C-13 when the proton NMR frequency is 600 MHz?",
            "What is the duration of a 90-degree pulse when the RF amplitude is 1 kHz?",
            "What is the acquisition time when the dwell time is 10 microseconds and there are 1024 points?"
        ]
        let navigationState = NMRAssistantNavigationState()
        for question in questions {
            let service = NMRAssistantService(navigationState: navigationState)
            await service.send(question)

            XCTAssertEqual(service.messages.count, 2, "Expected a reply to: \(question)")
            guard let reply = service.messages.last, reply.role == .assistant else {
                XCTFail("Missing assistant reply to: \(question)")
                continue
            }
            XCTAssertFalse(reply.text.hasPrefix("Error:"), "Assistant failed on: \(question) — \(reply.text)")
            print("**********\nQ: \(question)\nA: \(reply.text)\n**********")
        }
    }

    /// Estimates the prompt overhead of the NMR assistant's main session:
    /// the instructions plus each tool's name, description, and argument schema.
    /// The runtime renders tool definitions in a private format, so the schema
    /// JSON used here is an approximation — absolute numbers are estimates,
    /// but before/after comparisons of the same components are meaningful.
    @MainActor
    func testTokenCount() async throws {
        guard #available(iOS 26.4, *) else {
            throw XCTSkip("SystemLanguageModel.tokenCount(for:) requires iOS 26.4")
        }
        guard case .available = SystemLanguageModel.default.availability else {
            throw XCTSkip("The language model is unavailable")
        }
        let model = SystemLanguageModel.default

        func pad(_ name: String) -> String {
            name.padding(toLength: 36, withPad: " ", startingAt: 0)
        }

        let instructionTokens = try await model.tokenCount(for: NMRAssistantService.instructions)
        var lines = ["[TokenCount] \(pad("instructions")) \(instructionTokens)"]
        var total = instructionTokens

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let tools = NMRAssistantService.makeTools(navigationState: NMRAssistantNavigationState())
        for tool in tools {
            let schema = String(data: try encoder.encode(tool.parameters), encoding: .utf8) ?? ""
            let rendered = "\(tool.name): \(tool.description)\n\(schema)"
            let tokens = try await model.tokenCount(for: rendered)
            lines.append("[TokenCount] \(pad(tool.name)) \(tokens)")
            total += tokens
        }
        lines.append("[TokenCount] \(pad("estimated total")) \(total)")
        print(lines.joined(separator: "\n"))

        XCTAssertGreaterThan(instructionTokens, 0)
        XCTAssertGreaterThan(total, instructionTokens)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
