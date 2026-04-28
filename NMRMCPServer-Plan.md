# NMR MCP Server — Implementation Plan

## Overview

Add a new **macOS Command Line Tool** target (`NMRMCPServer`) to the existing Xcode project. It links against `NMRCalcCommon` and speaks the MCP stdio transport (newline-delimited JSON-RPC 2.0 over stdin/stdout).

---

## Phase 1 — Add the Xcode Target

1. In Xcode: **File → New → Target → macOS → Command Line Tool**, name it `NMRMCPServer`.
2. Set minimum macOS to **13.3** and Swift version to **Swift 6** (matching `NMRCalcForMac`).
3. Under "Frameworks and Libraries", add **`NMRCalcCommon.framework`**.
4. Fix the resource loading issue: `NMRPeriodicTable` currently calls `Bundle.main` to find `NMRFreqTable.txt`, which won't work from a CLI tool binary. Change one line in `NMRPeriodicTable.swift` to use `Bundle(for: NMRPeriodicTable.self)` instead — this points to the framework bundle where the file already lives, no file duplication needed.

---

## Phase 2 — Source Files (3 files)

**`main.swift`** — Entry point. Uses `@MainActor` to satisfy `NMRPeriodicTable`'s actor isolation, then runs the server loop.

```swift
import Foundation

// NMRPeriodicTable is @MainActor; warm it up here.
await MainActor.run { _ = NMRPeriodicTable.shared }
try await MCPServer().run()
```

**`MCPServer.swift`** — The JSON-RPC 2.0 stdio loop.
- Read a line from stdin.
- Decode it as a `JSONRPCRequest` (using `Codable`).
- Dispatch on `method`: `initialize`, `tools/list`, `tools/call`.
- Encode and write the `JSONRPCResponse` to stdout, followed by a newline.
- Log errors to **stderr** only (stdout is reserved for the MCP wire protocol).

**`NMRTools.swift`** — Tool definitions and implementations.

---

## Phase 3 — Tools to Expose

| Tool name | Inputs | Output | Backed by |
|---|---|---|---|
| `calculate_larmor_frequency` | `nucleus` (e.g. `"1H"`), `magnetic_field` (T) | Larmor frequency in MHz | `LarmorFrequencyMagneticFieldConverter` |
| `calculate_magnetic_field` | `nucleus`, `larmor_frequency` (MHz) | B₀ in T | `LarmorFrequencyMagneticFieldConverter` |
| `get_nucleus_info` | `nucleus` | γ, spin, natural abundance | `NMRPeriodicTable.shared` |
| `list_nuclei` | — | all 120 nuclei | `NMRPeriodicTable.shared` |
| `calculate_ernst_angle` | `repetition_time` (s), `t1` (s) | Ernst angle in degrees | `ErnstAngleCalculator` |
| `calculate_pulse_amplitude` | `duration` (μs), `flip_angle` (deg) | RF amplitude in Hz | `Pulse` |
| `calculate_pulse_duration` | `flip_angle` (deg), `amplitude` (Hz) | duration in μs | `Pulse` |

For the example question ("NMR frequency of hydrogen at 7 T"), `calculate_larmor_frequency` looks up ¹H's γ = 42.577 MHz/T from `NMRPeriodicTable`, multiplies by 7 T, and returns 297.90 MHz.

---

## Phase 4 — MCP Protocol (no external dependencies)

Implement from scratch with `Codable` structs and `Foundation`:

```swift
struct JSONRPCRequest: Decodable {
    let jsonrpc: String
    let id: JSONValue?        // String | Int | null
    let method: String
    let params: [String: JSONValue]?
}

struct JSONRPCResponse: Encodable {
    let jsonrpc = "2.0"
    let id: JSONValue?
    let result: JSONValue?
    let error: JSONRPCError?
}
```

`JSONValue` is an indirect `enum` covering `string`, `double`, `bool`, `array`, `object`, `null` — about 30 lines of `Codable` boilerplate, nothing exotic.

**Methods the server must handle:**

| Method | Action |
|---|---|
| `initialize` | Return server name, version, and `{"tools": {}}` capability |
| `notifications/initialized` | No response (it is a notification, not a request) |
| `tools/list` | Return array of tool definitions with JSON Schema for their inputs |
| `tools/call` | Execute the named tool, return `{"content": [{"type": "text", "text": "..."}]}` |

---

## Phase 5 — Build & Install

```bash
# Build release binary
xcodebuild -scheme NMRMCPServer -destination 'platform=macOS' -configuration Release

# Copy binary to a stable path
cp ~/Library/Developer/Xcode/DerivedData/NMRCalculator-.../NMRMCPServer \
   /usr/local/bin/NMRMCPServer
```

**Register with Claude Code** (add to `.claude/settings.json` in this repo, or to your global `~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "nmr-calculator": {
      "command": "/usr/local/bin/NMRMCPServer",
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
      "command": "/usr/local/bin/NMRMCPServer"
    }
  }
}
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Xcode target, not a separate Swift package | Reuses the existing `NMRCalcCommon` framework without duplicating physics logic |
| No external MCP SDK | The stdio transport is ~100 lines; keeping it in-tree avoids SPM/Xcode integration friction |
| `Bundle(for:)` fix | One-line change; avoids copying `NMRFreqTable.txt` into a second target |
| `@MainActor` warm-up at startup | `NMRPeriodicTable.shared` parses the 120-nucleus file once on launch; subsequent tool calls are instant |
| stderr for logging | Keeps stdout clean for the MCP wire protocol |
