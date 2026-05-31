//
//  NMRNucleusTableLoader.swift
//  NMRCalculatorCommon
//
//  Created by Jae Seung Lee on 5/31/26.
//

import Foundation
import Logging

public final class NMRNucleusTableLoader: Sendable {
    
    private static let logger = Logger(label: "NMRNucleusTableLoader")
    
    @MainActor public static let shared = NMRNucleusTableLoader()
    
    private let resourceName = "NMRFreqTable_2026" // Magnetic Dipole Moments: Part I, Long-Lived States. https://doi.org/10.61092/iaea.qs1q-27sa
    private let resourceExtension = "csv"
    
    private let table: [String]?
    
    private init() {
        Self.logger.info("Initializing...")
        
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: resourceExtension) else {
            Self.logger.error("\(resourceName) is not found.")
            self.table = nil
            return
        }
        
        do {
            self.table = try String(contentsOf: url, encoding: String.Encoding.utf8).components(separatedBy: "\n")
        } catch {
            Self.logger.error("Error: Cannot read the content of \(url): \(error.localizedDescription)")
            self.table = nil
        }
    }
    
    public var loaded: Bool {
        return table != nil
    }

    public func nmrNucleusTable() -> [NMRNucleus] {
        var result = [NMRNucleus]()
        
        if let table = table {
            for row in table {
                let row = row.trimmingCharacters(in: .whitespacesAndNewlines)
                if !row.isEmpty {
                    let stringArray = row.split(separator: ",").map(String.init)
                    result.append(NMRNucleus(data: stringArray))
                }
            }
        }
        
        return result
    }
    
}
