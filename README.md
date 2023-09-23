# NMRCalculator 2

You may clone or download the source from the GitHub [repository](https://github.com/jaeseung16/NMRCalculator). Or
install the app from the App Store.

[<img src="./docs/assets/images/App_Store_Badge.svg">](https://apps.apple.com/app/id6466729022)

The app is tested with `Swift 4` and `Xcode 9.2`.

## Description

The app evaluates the values of some basic parameters used in nuclear magnetic resonance (NMR) spectroscopy.

### Nucleus
- Select an isotope with non-zero nuclear spin to find out its nuclear spin, gyromagnetic ratio, and natural abundance.
- For a chosen isotope, its Larmor frequency at a specified external magnetic field together with the Larmor frequencies of the proton and free electron will be shown.
- One may change any of the Larmor frequency, external magnetic field, and proton’s Larmor frequency to find out the other two.
- The information on the chosen isotope can be searched in Safari by pressing the "Search Web" button.

### Signal
- One of the number of data points, duration, and dwell time for signal acquisition is calculated when two of them are given.
- One of the number of data points, spectral width, and frequency resolution for a NMR spectrum is calculated when two of them are given.
- One of the items can be deactivated by tabbing the corresponding label. While deactivated, the value will not be changed, and the calculation will be performed accordingly.

### RF Pulse
- One of the pulse duration, flip angle, and RF amplitude of a RF pulse is calculated when two of them are given.
- The difference between the power levels of two RF pulses is presented in dB.
- One of the repetition time, relaxation time, and Ernst angle is calculated when two of them are given.
- One of the items, except "RF power relative to 1st (dB)", can be deactivated by tabbing the corresponding label. While deactivated, the value will not be changed, and the calculation will be performed accordingly.

### Solution
- The concentration of a sample solution is calculated when the molecular weight and the masses of the solute and solvent water are given.
- The amount of the solute is calculated when the concentration is given.
- The name of chemical can be entered.

### Info
- The data source for NMR-enabled isotopes and formulas used in the app are presented.

---
#### History
- Version 1.0 / Aug 24, 2016
- Version 1.1 / Sep 28, 2016
- Version 1.2 / Nov 1, 2017

