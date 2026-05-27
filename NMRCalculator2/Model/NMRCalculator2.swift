//
//  NMRCalc2ViewModel.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation
import os
import NMRCalculatorCommon

class NMRCalculator2: ObservableObject {
    private let logger = Logger()
    
    private let nucleus: NMRNucleus
    
    private let larmorFrequencyCalculator: LarmorFrequencyMagneticFieldConverter
    private let timeDomainCalculator: DwellAcquisitionTimeConverter
    private let frequencyDomainCalculator: SpectralWidthFrequencyResolutionConverter
    private let ernstAngleCalculator: ErnstAngleConverter
    private let decibelCalculator: DecibelConverter
    private let pulseParameterCalculator1: PulseParameterConverter
    private let pulseParameterCalculator2: PulseParameterConverter
    
    private let pulse1: Pulse
    private let pulse2: Pulse
    
    private var commands: [NMRCalcCommandName: NMRCalcCommand]
    
    private var commandsForPulse1: Set<NMRCalcCommandName>
    private var commandsForPulse2: Set<NMRCalcCommandName>
    
    @Published var updated = false
    @Published var showAlert = false
    var alertMessage = ""
    
    init(nucleus: NMRNucleus) {
        self.nucleus = nucleus
        
        self.larmorFrequencyCalculator = LarmorFrequencyMagneticFieldConverter(nucleus: nucleus, magneticField: 1.0)
        commands = [NMRCalcCommandName: NMRCalcCommand]()
        commands[.larmorFrequency] = UpdateLarmorFrequency(larmorFrequencyCalculator)
        commands[.magneticField] = UpdateMagneticField(larmorFrequencyCalculator)
        commands[.protonFrequency] = UpdateProtonFrequency(larmorFrequencyCalculator)
        commands[.electronFrequency] = UpdateElectronFrequency(larmorFrequencyCalculator)
        
        self.ernstAngleCalculator = ErnstAngleConverter(repetitionTime: 1.0, relaxationTime: 1.0)
        commands[.ernstAngle] = UpdateErnstAngle(ernstAngleCalculator)
        commands[.repetitionTime] = UpdateRepetitionTime(ernstAngleCalculator)
        commands[.relaxationTime] = UpdateRelaxationTime(ernstAngleCalculator)
        
        self.timeDomainCalculator = DwellAcquisitionTimeConverter(acqusitionTime: 1.0, numberOfPoints: 1000)
        commands[.acquisitionTime] = UpdateAcquisitionTime(timeDomainCalculator)
        commands[.dwellTime] = UpdateDwellTime(timeDomainCalculator)
        commands[.dwellTimeInμs] = UpdateDwellTimeInμs(timeDomainCalculator)
        commands[.acquisitionSize] = UpdateAcquisitionSize(timeDomainCalculator)
        
        self.frequencyDomainCalculator = SpectralWidthFrequencyResolutionConverter(spectralWidth: 1000.0, numberOfPoints: 1000)
        commands[.spectrumSize] = UpdateSpectrumSize(frequencyDomainCalculator)
        commands[.frequencyResolution] = UpdateFrequencyResolution(frequencyDomainCalculator)
        commands[.spectralWidth] = UpdateSpectralWidth(frequencyDomainCalculator)
        commands[.spectralWidthInkHz] = UpdateSpectralWidthInkHz(frequencyDomainCalculator)
        
        self.pulse1 = Pulse(duration: 10.0, flipAngle: 90.0)
        self.pulseParameterCalculator1 = PulseParameterConverter(pulse: pulse1, nucleus: nucleus)
        commands[.pulse1Duration] = UpdatePulseDuration(pulseParameterCalculator1)
        commands[.pulse1Amplitude] = UpdatePulseAmplitude(pulseParameterCalculator1)
        commands[.pulse1FlipAngle] = UpdatePulseFlipAngle(pulseParameterCalculator1)
        commands[.pulse1AmplitudeInT] = UpdatePulseAmplitudeInT(pulseParameterCalculator1)
        self.commandsForPulse1 = [.pulse1Duration, .pulse1Amplitude, .pulse1FlipAngle, .pulse1AmplitudeInT]
        
        self.pulse2 = Pulse(duration: 1000.0, flipAngle: 90.0)
        self.pulseParameterCalculator2 = PulseParameterConverter(pulse: pulse2, nucleus: nucleus)
        commands[.pulse2Duration] = UpdatePulseDuration(pulseParameterCalculator2)
        commands[.pulse2Amplitude] = UpdatePulseAmplitude(pulseParameterCalculator2)
        commands[.pulse2FlipAngle] = UpdatePulseFlipAngle(pulseParameterCalculator2)
        commands[.relativePower] = UpdateRelativePower(pulse2)
        self.commandsForPulse2 = [.pulse2Duration, .pulse2Amplitude, .pulse2FlipAngle]
        
        self.decibelCalculator = DecibelConverter(measured: pulse2.amplitude, reference: pulse1.amplitude, mode: .amplitude)
    }
    
    var nucleusName: String {
        nucleus.nameNucleus
    }
    
    // MARK: - Validation
    
    func isPositive(_ value: Double) -> Bool {
        return value > 0.0
    }
    
    func isNonNegative(_ value: Double) -> Bool {
        return value >= 0.0
    }
    
    func validate(externalField B0: Double) -> Bool {
        return abs(B0) <= 1000.0
    }
    
    func validate(numberOfDataPoints: Double) -> Bool {
        return numberOfDataPoints >= 1.0
    }
    
    func validate(ernstAngle: Double) -> Bool {
        return ernstAngle > 0.0 && ernstAngle < 90.0
    }
    
    func update(_ commandName: NMRCalcCommandName, to value: Double) -> Void {
        logger.log("command=\(commandName.rawValue, privacy: .public)")
        if let command = commands[commandName] {
            command.execute(with: value)
            updateRelativePower()
            updated.toggle()
            logger.log("updated=\(self.updated, privacy: .public)")
        } else {
            logger.log("Can't find any command named \(commandName.rawValue, privacy: .public)")
        }
    }
    
    // MARK: - Larmor frequency
    var γNucleus: Double {
        guard let γNucleus = Double(nucleus.gyromagneticRatio) else {
            return NMRCalcConstants.gammaProton
        }
        return γNucleus
    }
    
    var externalField: Double {
        larmorFrequencyCalculator.magneticField
    }
    
    var larmorFrequency: Double {
        larmorFrequencyCalculator.larmorFrequency
    }
    
    var protonFrequency: Double {
        larmorFrequencyCalculator.protonFrequency
    }
    
    var electronFrequency: Double {
        larmorFrequencyCalculator.electronFrequency
    }
    
    private var externalFieldFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var frequencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 6
        return formatter
    }
    
    var larmorFrequencies: CalculatorItems {
        var items = [CalculatorItem]()
        
        let externalField = CalculatorItem(command: .magneticField,
                                            title: NMRCalcConstants.Title.externalField,
                                            font: .callout,
                                            value: externalField,
                                            unit: .T,
                                            formatter: externalFieldFormatter) { newValue in
            if self.validate(externalField: newValue) {
                self.update(.magneticField, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBeBetweenNegativeOneThousandAndOneThousand.rawValue
            }
        }
        
        items.append(externalField)
        
        let larmorFrequency = CalculatorItem(command: .larmorFrequency,
                                            title: NMRCalcConstants.Title.larmorFrequency,
                                            font: .callout,
                                            value: larmorFrequency,
                                            unit: .MHz,
                                            formatter: frequencyFormatter) { newValue in
            self.update(.larmorFrequency, to: newValue)
        }
        
        items.append(larmorFrequency)
        
        let protonFrequency = CalculatorItem(command: .protonFrequency,
                                            title: NMRCalcConstants.Title.protonFrequency,
                                            font: .callout,
                                            value: protonFrequency,
                                            unit: .MHz,
                                            formatter: frequencyFormatter) { newValue in
            self.update(.protonFrequency, to: newValue)
        }
        
        items.append(protonFrequency)
        
        
        let electronFrequency = CalculatorItem(command: .electronFrequency,
                                            title: NMRCalcConstants.Title.electronFrequency,
                                            font: .callout,
                                            value: electronFrequency,
                                            unit: .GHz,
                                            formatter: frequencyFormatter) { newValue in
            self.update(.electronFrequency, to: newValue)
        }
        
        items.append(electronFrequency)
        
        return CalculatorItems(items: items)
    }
    
    // MARK: - Time Domain
    
    var numberOfTimeDataPoints: Double {
        Double(timeDomainCalculator.numberOfPoints)
    }
    
    var acquisitionDuration: Double {
        timeDomainCalculator.acqusitionTime
    }
    
    var dwellTime: Double {
        timeDomainCalculator.dwellInμs
    }
    
    private var dataPointsFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    private var durationTimeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var timeDomainFields: CalculatorItems {
        var items = [CalculatorItem]()
        
        let numberOfTimeDataPoints = CalculatorItem(command: .acquisitionSize,
                                                    title: NMRCalcConstants.Title.numberOfDataPoints,
                                                    font: .body,
                                                    value: numberOfTimeDataPoints,
                                                    unit: .none,
                                                    formatter: dataPointsFormatter) { newValue in
            if self.validate(numberOfDataPoints: newValue) {
                self.update(.acquisitionSize, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBeNaturalNumber.rawValue
            }
        }
        
        items.append(numberOfTimeDataPoints)
        
        let acquisitionDuration = CalculatorItem(command: .acquisitionTime,
                                                 title: NMRCalcConstants.Title.acquisitionDuration,
                                                 font: .body,
                                                 value: acquisitionDuration,
                                                 unit: .sec,
                                                 formatter: durationTimeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.acquisitionTime, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(acquisitionDuration)
        
        let dwellTime = CalculatorItem(command: .dwellTimeInμs,
                                       title: NMRCalcConstants.Title.dwellTime,
                                       font: .body,
                                       value: dwellTime,
                                       unit: .μs,
                                       formatter: durationTimeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.dwellTimeInμs, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(dwellTime)
        
        return CalculatorItems(items: items)
    }
    
    // MARK: - Frequency Domain
    
    var numberOfFrequencyDataPoints: Double {
        Double(frequencyDomainCalculator.numberOfPoints)
    }
    
    var spectralWidth: Double {
        frequencyDomainCalculator.spectralWidthInkHz
    }
    
    var frequencyResolution: Double {
        frequencyDomainCalculator.frequencyResolution
    }

    var frequencyDomainFields: CalculatorItems {
        var items = [CalculatorItem]()
        
        let numberOfFrequencyDataPoints = CalculatorItem(command: .spectrumSize,
                                                         title: NMRCalcConstants.Title.numberOfDataPoints,
                                                         font: .body,
                                                         value: numberOfFrequencyDataPoints,
                                                         unit: .none,
                                                         formatter: dataPointsFormatter) { newValue in
            if self.validate(numberOfDataPoints: newValue) {
                self.update(.spectrumSize, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBeNaturalNumber.rawValue
            }
        }
        
        items.append(numberOfFrequencyDataPoints)
        
        let spectralWidth = CalculatorItem(command: .spectralWidthInkHz,
                                           title: NMRCalcConstants.Title.spectralWidth,
                                           font: .body,
                                           value: spectralWidth,
                                           unit: .kHz,
                                           formatter: durationTimeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.spectralWidthInkHz, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(spectralWidth)
        
        let frequencyResolution = CalculatorItem(command: .frequencyResolution,
                                                 title: NMRCalcConstants.Title.frequencyResolution,
                                                 font: .body,
                                                 value: frequencyResolution,
                                                 unit: .Hz,
                                                 formatter: durationTimeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.frequencyResolution, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(frequencyResolution)
        
        return CalculatorItems(items: items)
    }
    
    // MARK: - Pulse
    var duration1: Double {
        pulse1.duration
    }
    
    var flipAngle1: Double {
        pulse1.flipAngle
    }

    var amplitude1: Double {
        pulse1.amplitude
    }

    var amplitude1InT: Double {
        pulse1.amplitude / γNucleus
    }
    
    func update(pulse1AmplitudeInT: Double) -> Void {
        update(.pulse1Amplitude, to: pulse1AmplitudeInT * γNucleus)
    }
    
    private var amplitudeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var durationFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var relativePowerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var pulse1Fields: CalculatorItems {
        var items = [CalculatorItem]()
        
        let duration1 = CalculatorItem(command: .pulse1Duration,
                                       title: NMRCalcConstants.Title.pulseDuration,
                                       font: .body,
                                       value: duration1,
                                       unit: .μs,
                                       formatter: durationFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.pulse1Duration, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(duration1)
        
        let flipAngle1 = CalculatorItem(command: .pulse1FlipAngle,
                                        title: NMRCalcConstants.Title.flipAngle,
                                        font: .body,
                                        value: flipAngle1,
                                        unit: .degree,
                                        formatter: flipAngleFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.pulse1FlipAngle, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(flipAngle1)
        
        let amplitude1 = CalculatorItem(command: .pulse1Amplitude,
                                        title: NMRCalcConstants.Title.rfAmplitude,
                                        font: .body,
                                        value: amplitude1,
                                        unit: .Hz,
                                        formatter: amplitudeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.pulse1Amplitude, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(amplitude1)
        
        let amplitude1InT = CalculatorItem(command: .pulse1AmplitudeInT,
                                           title: NMRCalcConstants.Title.rfAmplitudeInμT,
                                           font: .body,
                                           value: amplitude1InT,
                                           unit: .μT,
                                           formatter: amplitudeFormatter) { newValue in
            if self.isPositive(abs(newValue)) {
                self.update(pulse1AmplitudeInT: self.γNucleus >= 0 ? abs(newValue) : -abs(newValue))
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(amplitude1InT)
        
        return CalculatorItems(items: items)
    }
    
    var duration2: Double {
        pulse2.duration
    }
    
    var flipAngle2: Double {
        pulse2.flipAngle
    }
    
    var amplitude2: Double {
        pulse2.amplitude
    }
    
    var relativePower: Double {
        decibelCalculator.dB
    }
    
    var pulse2Fields: CalculatorItems {
        var items = [CalculatorItem]()
        
        let duration2 = CalculatorItem(command: .pulse2Duration,
                                       title: NMRCalcConstants.Title.pulseDuration,
                                       font: .body,
                                       value: duration2,
                                       unit: .μs,
                                       formatter: durationFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.pulse2Duration, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(duration2)
        
        let flipAngle2 = CalculatorItem(command: .pulse2FlipAngle,
                                        title: NMRCalcConstants.Title.flipAngle,
                                        font: .body,
                                        value: flipAngle2,
                                        unit: .degree,
                                        formatter: flipAngleFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.pulse2FlipAngle, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(flipAngle2)
        
        let amplitude2 = CalculatorItem(command: .pulse2Amplitude,
                                        title: NMRCalcConstants.Title.rfAmplitude,
                                        font: .body,
                                        value: amplitude2,
                                        unit: .Hz,
                                        formatter: amplitudeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.pulse2Amplitude, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(amplitude2)
        
        let relativePower = CalculatorItem(command: .relativePower,
                                           title: NMRCalcConstants.Title.rfPowerRelativeToPulse1,
                                           font: .body,
                                           value: relativePower,
                                           unit: .dB,
                                           formatter: relativePowerFormatter) { newValue in
            self.decibelCalculator.set(dB: newValue, mode: .amplitude)
            self.update(.pulse2Amplitude, to: self.decibelCalculator.measured)
        }
        
        items.append(relativePower)
        
        return CalculatorItems(items: items)
    }
    
    private func updateRelativePower() -> Void {
        decibelCalculator.update(measured: amplitude2, reference: amplitude1, mode: .amplitude)
    }
    
    // MARK: - Ernst Angle
    var repetitionTime: Double {
        ernstAngleCalculator.repetitionTime
    }
    
    var relaxationTime: Double {
        ernstAngleCalculator.relaxationTime
    }
    
    var ernstAngle: Double {
        ernstAngleCalculator.ernstAngle
    }
    
    private var relaxationTimeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var flipAngleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var ernstAngles: CalculatorItems {
        var items = [CalculatorItem]()
        
        let repetitionItem = CalculatorItem(command: .repetitionTime,
                                            title: NMRCalcConstants.Title.repetitionTime,
                                            font: .body,
                                            value: repetitionTime,
                                            unit: .sec,
                                            formatter: relaxationTimeFormatter) { newValue in
            if self.isNonNegative(newValue) {
                self.update(.repetitionTime, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(repetitionItem)
        
        let relaxationTime = CalculatorItem(command: .relaxationTime,
                                            title: NMRCalcConstants.Title.relaxationTime,
                                            font: .body,
                                            value: relaxationTime,
                                            unit: .sec,
                                            formatter: relaxationTimeFormatter) { newValue in
            if self.isPositive(newValue) {
                self.update(.relaxationTime, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBePositiveValue.rawValue
            }
        }
        
        items.append(relaxationTime)
        
        let ernstAngle = CalculatorItem(command: .ernstAngle,
                                        title: NMRCalcConstants.Title.ernstAngle,
                                        font: .body,
                                        value: ernstAngle,
                                        unit: .degree,
                                        formatter: flipAngleFormatter) { newValue in
            if self.validate(ernstAngle: newValue) {
                self.update(.ernstAngle, to: newValue)
            } else {
                self.showAlert.toggle()
                self.alertMessage = CalculatorErrorMessage.shouldBeBetweenZeroAndNinety.rawValue
            }
        }
        
        items.append(ernstAngle)
        
        return CalculatorItems(items: items)
    }
    
    // MARK: - Update values
    func refresh(_ items: CalculatorItems) {
        items.items.forEach { item in
            switch item.id {
            case .acquisitionSize:
                item.value = self.numberOfTimeDataPoints
            case .magneticField:
                item.value = self.externalField
            case .larmorFrequency:
                item.value = self.larmorFrequency
            case .protonFrequency:
                item.value = self.protonFrequency
            case .electronFrequency:
                item.value = self.electronFrequency
            case .acquisitionTime:
                item.value = self.acquisitionDuration
            case .dwellTime:
                item.value = self.timeDomainCalculator.dwell
            case .dwellTimeInμs:
                item.value = self.dwellTime
            case .spectrumSize:
                item.value = self.numberOfFrequencyDataPoints
            case .frequencyResolution:
                item.value = self.frequencyResolution
            case .spectralWidth:
                item.value = self.frequencyDomainCalculator.spectralWidth
            case .spectralWidthInkHz:
                item.value = self.spectralWidth
            case .pulse1Duration:
                item.value = self.duration1
            case .pulse2Duration:
                item.value = self.duration2
            case .pulse1FlipAngle:
                item.value = self.flipAngle1
            case .pulse2FlipAngle:
                item.value = self.flipAngle2
            case .pulse1Amplitude:
                item.value = self.amplitude1
            case .pulse2Amplitude:
                item.value = self.amplitude2
            case .ernstAngle:
                item.value = self.ernstAngle
            case .repetitionTime:
                item.value = self.repetitionTime
            case .relaxationTime:
                item.value = self.relaxationTime
            case .pulse1AmplitudeInT:
                item.value = self.amplitude1InT
            case .relativePower:
                item.value = self.relativePower
            }
            
        }
    }
    
    func items(for calculationType: CalculationType) -> CalculatorItems {
        switch calculationType {
        case .larmorFrequency:
            return larmorFrequencies
        case .timeDomain:
            return timeDomainFields
        case .frequencyDomain:
            return frequencyDomainFields
        case .pulse1:
            return pulse1Fields
        case .pulse2:
            return pulse2Fields
        case .ernstAngle:
            return ernstAngles
        }
    }
    
}
