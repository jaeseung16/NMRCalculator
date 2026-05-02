# NMR MCP Server — Implementation Plan

## Overview

A new **macOS Command Line Tool** target (`NMRCalculatorMCPServer`) has been added to the existing Xcode project. It uses the official **MCP Swift SDK** for the protocol layer and calls into a self-contained copy of `NMRPeriodicTable` (plus `NMRNucleus` via Target Membership) for the physics data.

---

## Phase 1 — Xcode Target Setup ✅

1. Added target: **`NMRCalculatorMCPServer`** (macOS Command Line Tool).
2. Added `NMRNucleus.swift` (from `NMRCalcCommon`) to the target via **Target Membership**.
3. Created a self-contained **`NMRPeriodicTable.swift`** in `NMRCalculatorMCPServer/` — already uses `Bundle(for: NMRPeriodicTable.self)` so no `Bundle.main` issue.

**Remaining task — add `NMRFreqTable.txt` to Copy Bundle Resources:**
- Select the `NMRCalculatorMCPServer` target → **Build Phases → Copy Bundle Resources → +**
- Add `NMRCalcCommon/Assets/NMRFreqTable.txt`
- This is required because `NMRPeriodicTable.self` is defined in the CLI executable, so `Bundle(for:)` resolves to `Bundle.main` (the executable's own bundle).

---

## Phase 2 — MCP Swift SDK Dependency

Add the official SDK via **File → Add Package Dependencies...**:

| Field | Value |
|---|---|
| URL | `https://github.com/modelcontextprotocol/swift-sdk` |
| Product to link | `MCP` |
| Target | `NMRCalculatorMCPServer` |

This replaces the originally planned from-scratch JSON-RPC implementation. The SDK handles the stdio transport, JSON-RPC framing, `initialize` handshake, and `notifications/initialized` automatically.

---

## Phase 3 — Source Files

### `main.swift` ✅

```swift
import Foundation
import MCP

await MainActor.run { _ = NMRPeriodicTable.shared }

let server = Server(
    name: "nmr-calculator",
    version: "1.0.0",
    capabilities: .init(tools: .init())
)

await server.withMethodHandler(ListTools.self) { _ in
    ListTools.Result(tools: NMRTools.definitions)
}

await server.withMethodHandler(CallTool.self) { params in
    try await NMRTools.handle(params)
}

let transport = StdioTransport()
try await server.run(transport: transport)
```

> Consult the SDK README for the exact `Server` initializer and handler registration API, as it evolves.

### `NMRPeriodicTable.swift` ✅

Self-contained copy in `NMRCalculatorMCPServer/`. Uses `Bundle(for: NMRPeriodicTable.self)` to locate `NMRFreqTable.txt`.

### `NMRTools.swift` — **TODO**

Holds two things:
- `static var definitions: [Tool]` — array of tool definitions with JSON Schema for inputs
- `static func handle(_ params: CallTool.Parameters) async throws -> CallTool.Result` — dispatches to the per-tool implementations below

---

## Phase 4 — Tools to Implement (in `NMRTools.swift`)

| Tool name | Inputs | Output | Physics |
|---|---|---|---|
| `calculate_larmor_frequency` | `nucleus` (e.g. `"1H"`), `magnetic_field` (T) | Larmor frequency in MHz | ω = γ × B₀ |
| `calculate_magnetic_field` | `nucleus`, `larmor_frequency` (MHz) | B₀ in T | B₀ = ω / γ |
| `get_nucleus_info` | `nucleus` | γ, spin, natural abundance | `NMRPeriodicTable.shared` lookup |
| `list_nuclei` | — | all 120 nuclei with identifier and γ | `NMRPeriodicTable.shared.nuclei` |
| `calculate_ernst_angle` | `repetition_time` (s), `t1` (s) | Ernst angle in degrees | θ = arccos(exp(−TR/T₁)) |
| `calculate_pulse_amplitude` | `duration` (μs), `flip_angle` (deg) | RF amplitude in Hz | A = (θ/360°) / τ |
| `calculate_pulse_duration` | `flip_angle` (deg), `amplitude` (Hz) | duration in μs | τ = (θ/360°) / A |

**Example:** "NMR frequency of hydrogen at 7 T" → `calculate_larmor_frequency(nucleus: "1H", magnetic_field: 7.0)` → looks up ¹H γ = 42.577 MHz/T → returns **297.90 MHz**.

Nucleus lookup accepts both identifier formats: `"1H"` (plain) and `"¹H"` (Unicode superscript), checking both `nucleiDictionary` and `nucleiById`.

---

## Phase 5 — Build & Install

```bash
# Build release binary
xcodebuild -scheme NMRCalculatorMCPServer -destination 'platform=macOS' -configuration Release

# Copy binary to a stable path (adjust DerivedData hash as needed)
cp ~/Library/Developer/Xcode/DerivedData/NMRCalculator-.../NMRCalculatorMCPServer \
   /usr/local/bin/NMRCalculatorMCPServer
```

**Register with Claude Code** (`.claude/settings.json` in this repo, or `~/.claude/settings.json` globally):

```json
{
  "mcpServers": {
    "nmr-calculator": {
      "command": "/usr/local/bin/NMRCalculatorMCPServer",
      "type": "stdio"
    }
  }
}
```

**Register with Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "nmr-calculator": {
      "command": "/usr/local/bin/NMRCalculatorMCPServer"
    }
  }
}
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Self-contained `NMRPeriodicTable.swift` in the target | Avoids linking `NMRCalcCommon.framework`; only `NMRNucleus.swift` is shared via Target Membership |
| Official MCP Swift SDK (`swift-sdk`) | Handles JSON-RPC framing, initialize handshake, and transport — no hand-rolled protocol code needed |
| `Bundle(for: NMRPeriodicTable.self)` | Correct for a CLI executable where `Bundle.main` is the product directory; requires `NMRFreqTable.txt` in Copy Bundle Resources |
| `@MainActor` warm-up at startup | `NMRPeriodicTable.shared` parses 120 nuclei once on launch; all subsequent tool calls are instant dictionary lookups |
| stderr for logging | Keeps stdout clean for the MCP wire protocol |
