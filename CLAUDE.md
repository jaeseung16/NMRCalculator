# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

This is a standard Xcode project with no Makefile, fastlane, or CI scripts. All builds are driven by `xcodebuild` or the Xcode IDE.

```bash
# Build a specific scheme
xcodebuild -scheme NMRCalculator2 -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild -scheme NMRCalcForMac -destination 'platform=macOS'

# Run unit tests for iOS ViewModel
xcodebuild test -scheme NMRCalculator2 -destination 'platform=iOS Simulator,name=iPhone 16'

# Run unit tests for macOS ViewModel
xcodebuild test -scheme MacNMRCalculatorViewModelTest -destination 'platform=macOS'

# Run a single test class
xcodebuild test -scheme MacNMRCalculatorViewModelTest -destination 'platform=macOS' \
  -only-testing:MacNMRCalculatorViewModelTest/MacNMRCalculatorViewModelTest
```

## Project Targets

| Target | Platform | Min OS | Notes |
|---|---|---|---|
| NMRCalculator2 | iOS/iPadOS | iOS 18.0 | Current SwiftUI app |
| NMRCalcForMac | macOS | macOS 13.3 | SwiftUI macOS app |
| WatchNMRCalculator2 Watch App | watchOS | watchOS 11.0 | Current watch app |
| NMRCalcCommon | All | — | Shared framework (models, commands, views) |
| NMRCalculator (legacy) | iOS | iOS 12.0 | UIKit-based, do not extend |
| NMRCalc (legacy) | macOS | macOS 11.1 | Storyboard-based, do not extend |

The legacy targets (`NMRCalculator` UIKit and `NMRCalc` Storyboard) are kept for historical reference; all new work goes into the SwiftUI targets and `NMRCalcCommon`.

## Architecture

The project uses **MVVM + Command Pattern** with a shared framework.

### Layers

```
Platform Views (SwiftUI)
    ↓  @EnvironmentObject / @StateObject
ViewModels  (NMRCalculator2, MacNMRCalculatorViewModel)
    ↓  command dictionary dispatch
Commands  (NMRCalcCommon/Command/)  →  Converters (NMRCalcCommon/Model/)
```

### NMRCalcCommon (Shared Framework)

All physics calculation logic lives here, shared across iOS, macOS, and watchOS:

- **`Model/`** — Parameter converters encapsulate multi-variable NMR relationships:
  - `LarmorFrequencyMagneticFieldConverter` — Larmor frequency, B₀, gyromagnetic ratio
  - `DwellAcquisitionTimeConverter` — dwell time ↔ acquisition time
  - `SpectralWidthFrequencyResolutionConverter` — SW ↔ frequency resolution
  - `ErnstAngleCalculator` — Ernst angle from repetition time and T₁
  - `Pulse` — pulse duration, flip angle, and RF amplitude (3-parameter constraint)
  - `NMRNucleus` — nucleus data struct
- **`Command/`** — Command pattern wrapping converter calls:
  - `NMRCalcCommand` protocol — `execute(with value: Double)`
  - `NMRCalcCommandName` enum — 39 named commands
  - One file per command (e.g., `UpdateMagneticField`, `UpdateFlipAngle`)
- **`NMRPeriodicTable`** — Singleton loading nucleus data from `NMRFreqTable.txt`

### ViewModels

`NMRCalculator2` (iOS) and `MacNMRCalculatorViewModel` (macOS) are parallel implementations of the same pattern:

- Hold `commands: [NMRCalcCommandName: NMRCalcCommand]` dictionary
- Expose `@Published updated: Bool` and `@Published showAlert: Bool` for view refresh
- `update(_ commandName:, to value:)` — validates input, executes command, triggers refresh
- `items(for calculationType:)` — returns `[CalculatorItem]` for each of 6 calculator sections (Larmor, Time Domain, Frequency Domain, Pulse 1, Pulse 2, Ernst Angle)

### CalculatorItem Bridge

`CalculatorItem` (`NMRCalculator2/Model/`) is an `ObservableObject` that bundles:
- The `NMRCalcCommandName` to execute
- Display metadata (title, unit, `NumberFormatter`)
- Current value and validation/callback closure

Views bind to `CalculatorItem` instances as `@StateObject`. This decouples rendering from the ViewModel.

### Data Binding Flow

```
TextField input
  → CalculatorItem.callback()
  → NMRCalculator2.update(commandName, value)
  → commands[commandName].execute(value)
  → Converter.set(parameter)
  → @Published updated.toggle()
  → Views refresh via .onChange modifier
```

### Adding a New Calculable Parameter

1. Add the setter to the appropriate converter in `NMRCalcCommon/Model/`.
2. Add a new case to `NMRCalcCommandName` in `NMRCalcCommon/Command/`.
3. Create a new command file in `NMRCalcCommon/Command/` implementing `NMRCalcCommand`.
4. Register the command in `NMRCalculator2.init()` and `MacNMRCalculatorViewModel.init()`.
5. Add a `CalculatorItem` to the appropriate section in the ViewModel's `items(for:)`.

## Swift 6 Concurrency

The project was recently migrated to Swift 6 strict concurrency. All new code must satisfy Swift 6's actor isolation and Sendable requirements. The shared `NMRPeriodicTable` singleton is a particular area to be careful about thread safety.
