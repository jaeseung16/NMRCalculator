//
//  FrequencyDomainTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct FrequencyDomainTool: Tool {
    let name = "calculate_frequency_domain"
    let description = "Calculates spectral width, frequency resolution, or number of spectrum points. Provide two; the third is calculated."

    @Generable
    struct Arguments {
        @Guide(description: "Spectral width in kHz; omit to calculate it")
        var spectralWidthInKHz: Double?
        @Guide(description: "Number of data points; omit to calculate it")
        var numberOfPoints: Int?
        @Guide(description: "Frequency resolution in Hz; omit to calculate it")
        var frequencyResolutionInHz: Double?
    }

    func call(arguments: Arguments) async throws -> String {
        let request = FrequencyDomainRequest(
            spectralWidthInHz: arguments.spectralWidthInKHz.map { $0 * 1000.0 },
            numberOfPoints: arguments.numberOfPoints,
            frequencyResolutionInHz: arguments.frequencyResolutionInHz
        )
        switch NMRCalcFactory.shared.create(.frequency).process(request) {
        case .success(let r):
            guard let r = r as? FrequencyDomainResponse else { throw NMRCalcError.invalidOutput }
            return "Spectral width: \(String(format: "%.4f", r.spectralWidthInHz / 1000.0)) kHz, Points: \(r.numberOfPoints), Resolution: \(String(format: "%.4f", r.frequencyResolutionInHz)) Hz"
        case .failure(let error):
            throw error
        }
    }
}
