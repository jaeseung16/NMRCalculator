# NMR Assistant in NMRCalculator App

## Overview

An NMR Assistant chat interface embedded in the NMRCalculator2 iOS app. The user types a natural-language question; the assistant invokes the appropriate NMRCalculatorCommon calculator and replies with the numeric result. The feature is implemented using Apple's **Foundation Models** framework (`FoundationModels`, iOS 26+), which provides on-device LLM inference with structured **Tool** calling.

The assistant is accessible from `NuclearListView` via a toolbar button. One use case (opening a nucleus detail view) triggers in-app navigation rather than returning a number.

---

## Existing Infrastructure (NMRCalculatorCommon)

The shared framework already provides everything needed for calculation:

| Use case | Calculator class | Request type | Key fields |
|---|---|---|---|
| Ernst angle, repetition time, T₁ | `ErnstAngleCalculator` | `ErnstAngleRequest` | `ernstAngleInDegree?`, `repetitionTimeInSec?`, `relaxationTimeInSec?` |
| Spectral width / frequency resolution | `FrequencyDomainCalculator` | `FrequencyDomainRequest` | `spectralWidthInHz?`, `numberOfPoints?`, `frequencyResolutionInHz?` |
| Acquisition time / dwell time | `TimeDomainCalculator` | `TimeDomainRequest` | `acqusitionTimeInSec?`, `numberOfPoints?`, `dwellInSec?` |
| Relative pulse power (dB) | `DecibelCalculator` | `DecibelCalcualtionRequest` | `dB?`, `measured?`, `reference`, `mode` |
| Larmor / proton / B₀ | `LarmorFrequencyCalculator` | `LarmorFrequencyRequest` | `nucleus`, `magneticField?`, `larmorFrequency?`, `protonFrequency?`, `electronFrequency?` |
| Pulse RF amplitude / duration | `PulseParameterCalculator` | `PulseParameterRequest` | `durationInMicrosecond?`, `flipAngleInDegree?`, `amplitudeInHz?` |
| Nucleus lookup | `NMRPeriodicTable.shared` | — | `nucleiBySymbol`, `nucleiById` |

All calculators are reachable through `NMRCalcFactory.shared.create(_ type: CalculatorType)`.

---

## Architecture

```
NuclearListView (toolbar button)
    └── sheet → NMRAssistantView
                    ↕ @State / @Bindable
              NMRAssistantService (@Observable)
                    └── LanguageModelSession  (FoundationModels)
                              ↕ Tool calls
                    ┌─────────────────────────────┐
                    │  NMRAssistant Tools         │
                    │  (each conforms to Tool)    │
                    │  · ErnstAngleTool           │
                    │  · FrequencyDomainTool      │
                    │  · TimeDomainTool           │
                    │  · PulseRelativePowerTool   │
                    │  · LarmorFrequencyTool      │
                    │  · PulseAmplitudeTool       │
                    │  · NucleusListTool          │
                    │  · OpenNucleusDetailTool    │
                    └─────────────────────────────┘
                              ↓ calculation
                    NMRCalcFactory  →  NMRCalculatorCommon Calculators
                    NMRPeriodicTable.shared
```

**Navigation side-channel:** `OpenNucleusDetailTool` writes to a shared `NMRAssistantNavigationState` (`@Observable`). `NuclearListView` observes it and sets `selected` to trigger the `NavigationSplitView` detail pane.

---

## Platform Requirement

`FoundationModels` is a system framework requiring **iOS 26.0+** / macOS 26.0+ — no entitlement needed. `NMRCalculator2`, `NMRCalcForMac`, and `WatchNMRCalculator2` all already target iOS/macOS/watchOS 26.0, so `@available` guards are not required and `FoundationModels` can be imported unconditionally in those targets.

---

## New Files

All new files live inside `NMRCalculator2/NMRAssistant/`.

### `NMRAssistant/NMRAssistantNavigationState.swift`

```swift
@Observable
final class NMRAssistantNavigationState {
    var requestedNucleusID: NMRNucleus.ID?
}
```

Shared between `NMRAssistantService` (write) and `NuclearListView` (read). Passed through the environment.

---

### `NMRAssistant/NMRAssistantMessage.swift`

```swift
struct NMRAssistantMessage: Identifiable {
    enum Role { case user, assistant }
    let id: UUID
    let role: Role
    let text: String
}
```

Used by `NMRAssistantView` to render the conversation history.

---

### `NMRAssistant/NMRAssistantService.swift`

`@Observable` class.

Responsibilities:
- Creates and holds a `LanguageModelSession` configured with a system prompt describing the assistant's domain.
- Instantiates all tools (see below), injecting `navigationState` into `OpenNucleusDetailTool`.
- Exposes `messages: [NMRAssistantMessage]` and `isProcessing: Bool` for the view.
- `send(_ text: String) async` — appends user message, calls `session.respond(to:)`, appends assistant message.

System prompt summary: *"You are an NMR calculator assistant. Use the provided tools to answer questions about NMR parameters. Always include the numeric result and its unit in your reply."*

---

### `NMRAssistant/Tools/ErnstAngleTool.swift`

Conforms to `Tool`. Handles use cases 1 and 2 (independent group).

`Arguments` (`@Generable`):
- `relaxationTimeT1InSec: Double` — the T₁ relaxation time
- `repetitionTimeInSec: Double?` — provide to calculate Ernst angle
- `ernstAngleInDegree: Double?` — provide to calculate repetition time

Logic: build `ErnstAngleRequest` with the nil field absent, call `ErnstAngleCalculator().process(_:)`, return the computed field with unit.

---

### `NMRAssistant/Tools/FrequencyDomainTool.swift`

Handles use cases 3 and 4 (frequency resolution ↔ spectral width).

`Arguments`:
- `spectralWidthInKHz: Double?`
- `numberOfPoints: Int?`
- `frequencyResolutionInHz: Double?`

Exactly one of the three must be nil. Convert kHz→Hz before building `FrequencyDomainRequest`, convert result back to kHz for spectral width.

---

### `NMRAssistant/Tools/TimeDomainTool.swift`

Handles use cases 5 and 6 (acquisition time ↔ dwell time).

`Arguments`:
- `acquisitionTimeInSec: Double?`
- `numberOfPoints: Int?`
- `dwellTimeInMicrosec: Double?`

Convert µs→s before building `TimeDomainRequest`, convert result back.

---

### `NMRAssistant/Tools/PulseRelativePowerTool.swift`

Handles use case 7 (relative power in dB).

`Arguments`:
- `referencePulseDurationInMicrosec: Double`
- `referencePulseFlipAngleInDegree: Double`
- `measuredPulseDurationInMicrosec: Double`
- `measuredPulseFlipAngleInDegree: Double`

Compute amplitudes for both pulses using `PulseParameterCalculator` (pass the other two fields, nil for amplitude), then feed into `DecibelCalcualtionRequest(measured: amp2, reference: amp1, mode: .amplitude)`.

---

### `NMRAssistant/Tools/NucleusListTool.swift`

Handles nucleus use case 1 (list isotopes by element name or symbol).

`Arguments`:
- `elementNameOrSymbol: String`

Query `NMRPeriodicTable.shared.nuclei` filtering by `nameNucleus` or `symbolNucleus` (case-insensitive). Return a formatted list with identifier, nuclear spin, and γ (MHz/T). If empty, reply "No NMR-active isotopes found."

---

### `NMRAssistant/Tools/LarmorFrequencyTool.swift`

Handles nucleus use cases 2, 3, and 4 (Larmor frequency, B₀, proton frequency).

`Arguments`:
- `nucleusIdentifier: String` — e.g. `"1H"`, `"13C"`
- `magneticFieldInTesla: Double?`
- `larmorFrequencyInMHz: Double?`
- `protonFrequencyInMHz: Double?`
- `electronFrequencyInGHz: Double?`

Look up `NMRNucleus` from `NMRPeriodicTable.shared.nucleiById[nucleusIdentifier]`. Build `LarmorFrequencyRequest`, call `LarmorFrequencyCalculator().process(_:)`. Return B₀ (T), Larmor frequency (MHz), proton frequency (MHz).

---

### `NMRAssistant/Tools/PulseAmplitudeTool.swift`

Handles nucleus use case 5 (RF amplitude in Tesla/µT).

`Arguments`:
- `nucleusIdentifier: String`
- `durationInMicrosec: Double?`
- `flipAngleInDegree: Double?`
- `amplitudeInHz: Double?`

Look up nucleus for γ. Call `PulseParameterCalculator().process(_:)` to get `amplitudeInHz`. Convert to µT: `B1_µT = amplitudeInHz / γ_MHz_per_T` (since γ is in MHz/T = 10⁶ Hz/T, B1 in T = Hz / (γ × 10⁶), B1 in µT = Hz / γ). Return amplitude in both Hz and µT.

---

### `NMRAssistant/Tools/OpenNucleusDetailTool.swift`

Handles nucleus use case 6 (navigate to nucleus detail view).

`Arguments`:
- `nucleusIdentifier: String`

Sets `navigationState.requestedNucleusID = nucleusIdentifier` on the `@MainActor`. Returns a confirmation string to the model. The view layer observes this change and updates the split-view selection.

---

### `NMRAssistant/NMRAssistantView.swift`

SwiftUI view.

Layout:
- `ScrollView` with `LazyVStack` of message bubbles (user right-aligned, assistant left-aligned)
- `HStack` at bottom: `TextField` + send `Button`
- Shows a `ProgressView` when `service.isProcessing`

Binds to `NMRAssistantService` via `@State` (owned here) or passed in via the environment.

---

## Modified Files

### `NMRCalculator2/View/NuclearListView.swift`

1. Add `@Environment(NMRAssistantNavigationState.self)` binding.
2. Add `@State private var showAssistant = false`.
3. Add `.toolbar` with a button (SF Symbol: `bubble.left.and.text.bubble.right`).
4. Add `.sheet(isPresented: $showAssistant)` presenting `NMRAssistantView`.
5. Add `.onChange(of: navigationState.requestedNucleusID)` to set `selected` and dismiss the sheet.

### `NMRCalculator2App.swift`

1. Instantiate `NMRAssistantNavigationState` as a `@State` in the `App` struct.
2. Inject it into the environment: `.environment(navigationState)` on `ContentView`.

---

## Use Case ↔ Tool Mapping

| # | Use case | Tool |
|---|---|---|
| I-1 | Ernst angle from T₁ and TR | `ErnstAngleTool` (nil `ernstAngleInDegree`) |
| I-2 | Repetition time from T₁ and Ernst angle | `ErnstAngleTool` (nil `repetitionTimeInSec`) |
| I-3 | Frequency resolution from SW and N | `FrequencyDomainTool` (nil `frequencyResolutionInHz`) |
| I-4 | Spectral width from freq resolution and N | `FrequencyDomainTool` (nil `spectralWidthInKHz`) |
| I-5 | Acquisition duration from dwell and N | `TimeDomainTool` (nil `acquisitionTimeInSec`) |
| I-6 | Dwell time from acq duration and N | `TimeDomainTool` (nil `dwellTimeInMicrosec`) |
| I-7 | Relative power of two pulses | `PulseRelativePowerTool` |
| N-1 | List NMR isotopes for an element | `NucleusListTool` |
| N-2 | NMR frequency of isotope | `LarmorFrequencyTool` (provide B₀ or proton freq) |
| N-3 | External B₀ from isotope NMR frequency | `LarmorFrequencyTool` (provide `larmorFrequencyInMHz`) |
| N-4 | Proton frequency from isotope NMR frequency | `LarmorFrequencyTool` (provide `larmorFrequencyInMHz`) |
| N-5 | RF amplitude (T / µT) for a pulse | `PulseAmplitudeTool` |
| N-6 | Open nucleus detail view | `OpenNucleusDetailTool` |

---

## Implementation Steps

1. **No special entitlement required.** `FoundationModels` is a system framework — just `import FoundationModels` in source files. No Signing & Capabilities change is needed.
2. **No `@available` guards needed.** `NMRCalculator2` already targets iOS 26.0, so `FoundationModels` can be used unconditionally.
3. **Create `NMRAssistantNavigationState.swift`** and wire it through the app environment in `NMRCalculator2App.swift`.
4. **Implement tools** (8 files) in `NMRCalculator2/NMRAssistant/Tools/`, each using the appropriate `NMRCalculatorCommon` calculator.
5. **Implement `NMRAssistantService.swift`** — create `LanguageModelSession` with all tools registered.
6. **Implement `NMRAssistantView.swift`** — chat UI that talks to the service.
7. **Update `NuclearListView.swift`** — add toolbar button, sheet, and navigation observer.
8. **Test** each tool in isolation with `LanguageModelSession` (unit tests or Xcode previews with simulated model responses).

---

# Update: Per-Tool Sessions, Unit Normalization, and Response Evaluation

## Motivation

`SystemLanguageModel` has a small context window, and the main session's instructions currently carry a long per-tool unit-conversion rulebook (instruction item 2). The main session should focus on the conversation; the tools themselves should validate their inputs (including unit conversion) and their outputs should be evaluated before reaching the conversation. Tool outputs should also explicitly state **which** parameter was calculated, so the main model cannot confuse the computed value with an echoed input.

## Design principles

- **The on-device model never does arithmetic.** Per-tool `LanguageModelSession`s are used only for *classification*: mapping a free-form unit spelling (e.g. `"msec"`) onto a `@Generable` unit enum via guided generation (`respond(to:generating:)`). All numeric conversion and verification is deterministic Swift.
- **Deterministic-first.** A lookup table resolves common unit spellings; the classifier session is created (short-lived, per call) only on a table miss. This keeps latency low and avoids session-contention/Sendable issues in the `Tool` structs.
- **Round-trip output evaluation.** The calculated value is fed back into the calculator to solve for one of the *given* parameters (exercising a different code path); the result must reproduce the given value within a relative tolerance (1e-6). On failure the tool throws instead of returning a wrong number.
- **Explicit calculated parameter.** Tool output strings have the uniform shape `"Calculated <parameter> = <value> <unit> (given <inputs with units>)"`.
- **Context trade-off.** Adding unit fields grows each tool's argument schema (which also lives in the main session context), but deleting the unit-conversion instruction block more than compensates. Measure with `logTokenCount`; if schemas grow too much, collapse each value/unit pair into a single string argument (e.g. `"1.5 ms"`) parsed tool-side.

## Phase 1 — Shared support layer (`NMRAssistant/Support/`) ✅

- `UnitNormalizer.swift` ✅ — `@Generable` enums `TimeUnit` and `AngleUnit` (each with an `unrecognized` case so the classifier can express "not a unit of this dimension"); lookup tables; LLM fallback classifier; `seconds(from:unit:)` / `degrees(from:unit:)`. A nil/blank unit is taken as the canonical unit. Extend with `FrequencyUnit` (Hz, kHz, MHz, GHz) and `MagneticFieldUnit` (T, mT, G) when fanning out to the other tools.
- `ToolResponseEvaluator.swift` ✅ — round-trip verification; currently `verify(_:calculated:)` for `ErnstAngleResponse`, to be extended per calculator type.

## Phase 2 — Tool argument & flow changes (✅ `ErnstAngleTool`; other tools pending)

Pipeline in each calculation tool's `call(arguments:)`:
validate exactly-one-parameter-omitted → `UnitNormalizer` converts each input to canonical units → build request → process via `NMRCalcFactory` → `ToolResponseEvaluator` round-trip check → return explicit `"Calculated …"` string. Validation problems and unrecognized units return instructive strings (so the model can ask the user); calculator/verification failures throw.

- `ErnstAngleTool` ✅ — arguments are now value + unit-string pairs (`relaxationTimeT1`/`relaxationTimeT1Unit`, `repetitionTime`/`repetitionTimeUnit`, `ernstAngle`/`ernstAngleUnit`), all optional; exactly two must be provided and the third is calculated (the calculator also supports solving for T1, so the tool now exposes that too).
- Pending: `FrequencyDomainTool`, `TimeDomainTool`, `LarmorFrequencyTool`, `PulseAmplitudeTool`, `PulseRelativePowerTool`. `NucleusListTool` and `OpenNucleusDetailTool` need no changes (no units).

## Phase 3 — Slim down the main session (pending)

- Delete the unit-conversion instruction block (item 2) once all calculation tools normalize their own units; replace with one line: *"Pass values with the units exactly as the user stated them; the tools handle conversion."* (Item 2f for `calculate_ernst_angle` has already been rewritten this way.)
- Keep persona, nucleus-normalization rules, and the omit-the-calculated-parameter rule.
- Optional: a post-response **answer evaluator** session in `send(_:)` that compares the final `response.content` numbers against the latest tool outputs in `session.transcript` — the only place an LLM evaluator adds value beyond the deterministic check.

## Phase 4 — Tests (pending)

- Unit tests for `UnitNormalizer`'s deterministic table and conversions (no model required).
- Direct `call(arguments:)` tests per tool: calculated-parameter labeling, unit conversion (e.g. T1 = 1500 ms → 1.5 s), behavior on under-/over-specified arguments, evaluator rejection.
- Extend `testNMRAssistantService()` with unit-bearing phrasings from the existing question list.

## Risks / open points

- **Latency**: an LLM fallback inside a tool call adds a model round-trip while the main session is mid-`respond`. Deterministic-first keeps this rare; verify nested-session behavior on device.
- **Schema growth vs. instruction shrinkage**: confirm net token reduction with `tokenCount` after Phase 3.
- Nucleus-identifier normalization (instruction item 1) could later move tool-side the same way, further shrinking the main instructions.
