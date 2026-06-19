//
//  AssistantTextFormatter.swift
//  NMRCalculator2
//

import Foundation

/// Converts the raw text produced by the on-device language model into clean,
/// plain Unicode text suitable for `Text(verbatim:)`.
///
/// The model frequently emits LaTeX (`\(\omega = \gamma B_0\)`, `^{13}C`,
/// `T_1`) and Markdown (`*emphasis*`, `**bold**`) markup. SwiftUI's `Text`
/// renders none of the LaTeX, and only renders Markdown for compile-time string
/// literals — a runtime `String` shows the markup verbatim. Rather than feed the
/// model output through a Markdown renderer (which still can't handle LaTeX), we
/// translate the markup to Unicode and strip what has no Unicode equivalent.
///
/// This is applied to assistant messages only; user input is rendered as typed
/// so that a user who writes `2*3` is not reinterpreted.
enum AssistantTextFormatter {

    /// Returns a plain-text rendering of `raw` with LaTeX and Markdown markup
    /// translated to Unicode or removed. Idempotent on text that is already
    /// plain, so it is safe to apply to canned strings as well as model output.
    static func plainText(from raw: String) -> String {
        var text = raw

        // 1. LaTeX wrappers whose contents should survive verbatim.
        text = replace(text, pattern: #"\\(?:text|mathrm|mathbf|mathit|operatorname)\{([^{}]*)\}"#) { $0 }
        text = replace(text, pattern: #"\\frac\{([^{}]*)\}\{([^{}]*)\}"#, captures: 2) { caps in
            "\(caps[0])/\(caps[1])"
        }

        // 2. Super/subscripts — braced groups first, then bare digit/sign runs.
        text = replace(text, pattern: #"\^\{([^{}]*)\}"#) { superscript($0) }
        text = replace(text, pattern: #"_\{([^{}]*)\}"#) { subscriptText($0) }
        text = replace(text, pattern: #"\^([0-9]+)"#) { superscript($0) }
        text = replace(text, pattern: #"_([0-9]+)"#) { subscriptText($0) }
        text = replace(text, pattern: #"\^([+\-])"#) { superscript($0) }

        // 3. Named LaTeX commands → Unicode symbols.
        text = replace(text, pattern: #"\\([a-zA-Z]+)"#) { command in
            Self.commands[command] ?? command
        }

        // 4. LaTeX math delimiters and spacing macros.
        for token in ["\\(", "\\)", "\\[", "\\]", "$$", "$", "\\,", "\\;", "\\!"] {
            text = text.replacingOccurrences(of: token, with: "")
        }
        text = text.replacingOccurrences(of: "\\:", with: " ")

        // 5. Markdown emphasis and code/heading markers. Underscores are left
        //    alone (subscripts were already consumed above; residual ones are
        //    harmless and avoid mangling identifiers).
        text = text.replacingOccurrences(of: "**", with: "")
        text = text.replacingOccurrences(of: "*", with: "")
        text = text.replacingOccurrences(of: "`", with: "")
        text = replace(text, pattern: #"(?m)^\s*#{1,6}\s*"#) { _ in "" }

        // 6. Leftover braces and stray backslashes.
        text = text.replacingOccurrences(of: "{", with: "")
        text = text.replacingOccurrences(of: "}", with: "")
        text = text.replacingOccurrences(of: "\\", with: "")

        // 7. Collapse the whitespace the removals may have left behind.
        text = replace(text, pattern: #"[ \t]{2,}"#) { _ in " " }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Character maps

    private static func superscript(_ run: String) -> String {
        String(run.map { Self.superscripts[$0] ?? $0 })
    }

    private static func subscriptText(_ run: String) -> String {
        String(run.map { Self.subscripts[$0] ?? $0 })
    }

    private static let superscripts: [Character: Character] = [
        "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
        "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
        "+": "⁺", "-": "⁻", "=": "⁼", "(": "⁽", ")": "⁾", "n": "ⁿ", "i": "ⁱ"
    ]

    private static let subscripts: [Character: Character] = [
        "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
        "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉",
        "+": "₊", "-": "₋", "=": "₌", "(": "₍", ")": "₎",
        "a": "ₐ", "e": "ₑ", "o": "ₒ", "x": "ₓ", "h": "ₕ",
        "k": "ₖ", "l": "ₗ", "m": "ₘ", "n": "ₙ", "p": "ₚ", "s": "ₛ", "t": "ₜ"
    ]

    /// LaTeX commands the assistant is likely to emit for NMR physics. Keyed
    /// without the leading backslash. Unknown commands fall back to their bare
    /// name (the backslash is dropped) in step 3.
    private static let commands: [String: String] = [
        // Lowercase Greek
        "alpha": "α", "beta": "β", "gamma": "γ", "delta": "δ", "epsilon": "ε",
        "zeta": "ζ", "eta": "η", "theta": "θ", "iota": "ι", "kappa": "κ",
        "lambda": "λ", "mu": "μ", "nu": "ν", "xi": "ξ", "pi": "π", "rho": "ρ",
        "sigma": "σ", "tau": "τ", "phi": "φ", "chi": "χ", "psi": "ψ", "omega": "ω",
        // Uppercase Greek
        "Gamma": "Γ", "Delta": "Δ", "Theta": "Θ", "Lambda": "Λ", "Xi": "Ξ",
        "Pi": "Π", "Sigma": "Σ", "Phi": "Φ", "Psi": "Ψ", "Omega": "Ω",
        // Operators and relations
        "times": "×", "cdot": "·", "div": "÷", "pm": "±", "mp": "∓",
        "approx": "≈", "neq": "≠", "leq": "≤", "geq": "≥", "ll": "≪", "gg": "≫",
        "propto": "∝", "infty": "∞", "to": "→", "rightarrow": "→",
        "leftarrow": "←", "Rightarrow": "⇒", "sqrt": "√", "partial": "∂",
        "nabla": "∇", "angle": "∠", "hbar": "ℏ", "degree": "°", "circ": "°",
        // Spacing
        "quad": " ", "qquad": " ",
        // Delimiter-sizing macros that wrap an expression — drop the macro,
        // keep the bracket that follows it (e.g. \left( … \right) → ( … )).
        "left": "", "right": "", "big": "", "Big": "", "bigg": "", "Bigg": "",
        "bigl": "", "bigr": "", "Bigl": "", "Bigr": ""
    ]

    // MARK: - Regex helper

    /// Replaces every match of `pattern` (a single capture group by default)
    /// using `transform`, applied to the captured substring.
    private static func replace(_ input: String, pattern: String, transform: (String) -> String) -> String {
        replace(input, pattern: pattern, captures: 1) { transform($0[0]) }
    }

    private static func replace(_ input: String, pattern: String, captures: Int, transform: ([String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return input }
        let ns = input as NSString
        let matches = regex.matches(in: input, range: NSRange(location: 0, length: ns.length))
        guard !matches.isEmpty else { return input }

        var result = ""
        var lastEnd = 0
        for match in matches {
            result += ns.substring(with: NSRange(location: lastEnd, length: match.range.location - lastEnd))
            var caps: [String] = []
            for group in 1...max(captures, 1) {
                guard group < match.numberOfRanges else { caps.append(""); continue }
                let range = match.range(at: group)
                caps.append(range.location == NSNotFound ? "" : ns.substring(with: range))
            }
            result += transform(caps)
            lastEnd = match.range.location + match.range.length
        }
        result += ns.substring(from: lastEnd)
        return result
    }
}
