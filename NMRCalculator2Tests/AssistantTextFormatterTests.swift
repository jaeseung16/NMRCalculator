//
//  AssistantTextFormatterTests.swift
//  NMRCalculator2Tests
//
//  Deterministic tests for the LaTeX/Markdown → plain-Unicode sanitizer used to
//  render assistant messages. No language model is required.
//

import XCTest
@testable import NMRCalculator2

final class AssistantTextFormatterTests: XCTestCase {

    private func plain(_ raw: String) -> String {
        AssistantTextFormatter.plainText(from: raw)
    }

    // MARK: - Markdown emphasis

    func testStripsBoldAndItalicAsterisks() {
        XCTAssertEqual(plain("The **Larmor** frequency is *important*."),
                       "The Larmor frequency is important.")
    }

    func testStripsInlineCodeAndHeadings() {
        XCTAssertEqual(plain("# Result\nUse `gamma` here."), "Result\nUse gamma here.")
    }

    // MARK: - LaTeX delimiters

    func testStripsInlineMathDelimiters() {
        XCTAssertEqual(plain(#"The equation \(\omega = \gamma B_0\) holds."#),
                       "The equation ω = γ B₀ holds.")
    }

    func testStripsDisplayMathDelimiters() {
        XCTAssertEqual(plain(#"\[ \theta = \arccos(e) \]"#), "θ = arccos(e)")
    }

    func testStripsDollarMath() {
        XCTAssertEqual(plain(#"$\nu_0 = 400$ MHz"#), "ν₀ = 400 MHz")
    }

    // MARK: - Greek letters and operators

    func testConvertsGreekAndOperators() {
        XCTAssertEqual(plain(#"\gamma \times B_0 \approx \omega"#), "γ × B₀ ≈ ω")
    }

    func testUnknownCommandDropsBackslash() {
        XCTAssertEqual(plain(#"\unknowncmd value"#), "unknowncmd value")
    }

    // MARK: - Super/subscripts

    func testBracedSuperscriptForIsotope() {
        XCTAssertEqual(plain("^{13}C and ^{31}P"), "¹³C and ³¹P")
    }

    func testBareSubscriptDigits() {
        XCTAssertEqual(plain("B_0, T_1, and T_2"), "B₀, T₁, and T₂")
    }

    func testBracedSubscript() {
        XCTAssertEqual(plain("T_{1ρ}"), "T₁ρ")
    }

    func testSuperscriptCharge() {
        XCTAssertEqual(plain("Ca^{2+}"), "Ca²⁺")
    }

    func testFraction() {
        XCTAssertEqual(plain(#"\frac{TR}{T_1}"#), "TR/T₁")
    }

    func testDropsDelimiterSizingMacros() {
        XCTAssertEqual(plain(#"\left(\frac{a}{b}\right)"#), "(a/b)")
    }

    // MARK: - Robustness

    func testPlainTextIsUnchanged() {
        let s = "The Larmor frequency of 13C at 9.4 T is 100.6 MHz."
        XCTAssertEqual(plain(s), s)
    }

    func testIsIdempotent() {
        let raw = #"\(\omega = \gamma B_0\), **bold**, ^{13}C"#
        XCTAssertEqual(plain(plain(raw)), plain(raw))
    }

    func testCollapsesWhitespaceAndTrims() {
        XCTAssertEqual(plain("  value   with    gaps  "), "value with gaps")
    }
}
