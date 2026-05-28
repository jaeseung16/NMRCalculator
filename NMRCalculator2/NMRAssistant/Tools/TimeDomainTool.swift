//
//  TimeDomainTool.swift
//  NMRCalculator2
//

import FoundationModels
import NMRCalculatorCommon

struct TimeDomainTool: Tool {
    let name = "calculate_time_domain"
    let description = "Calculates acquisition time, dwell time, or number of acquisition points. Provide two; the third is calculated."

    @Generable
    struct Arguments {
        @Guide(description: "Acquisition time in seconds; omit to calculate it")
        var acquisitionTimeInSec: Double?
        @Guide(description: "Number of data points; omit to calculate it")
        var numberOfPoints: Int?
        @Guide(description: "Dwell time in microseconds; omit to calculate it")
        var dwellTimeInMicrosec: Double?
    }

    func call(arguments: Arguments) async throws -> String {
        let request = TimeDomainRequest(
            acqusitionTimeInSec: arguments.acquisitionTimeInSec,
            numberOfPoints: arguments.numberOfPoints,
            dwellInSec: arguments.dwellTimeInMicrosec.map { $0 / 1_000_000.0 }
        )
        switch NMRCalcFactory.shared.create(.time).process(request) {
        case .success(let r):
            guard let r = r as? TimeDomainResponse else { throw NMRCalcError.invalidOutput }
            return "Acquisition time: \(String(format: "%.6f", r.acqusitionTimeInSec)) s, Points: \(r.numberOfPoints), Dwell time: \(String(format: "%.4f", r.dwellInSec * 1_000_000.0)) µs"
        case .failure(let error):
            throw error
        }
    }
}
