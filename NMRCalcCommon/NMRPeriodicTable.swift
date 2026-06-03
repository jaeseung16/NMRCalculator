//
//  NMRNucleiTable.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 8/19/18.
//  Copyright © 2018 Jae-Seung Lee. All rights reserved.
//

import Foundation
import NMRCalculatorCommon

@MainActor
class NMRPeriodicTable {
    // MARK: - Properties
    static let shared = NMRPeriodicTable()
    let proton = NMRNucleus()
    var nuclei = [NMRNucleus]()
    var nucleiDictionary = [String: Int]()
    var nucleiById = [String: NMRNucleus]()
    var nucleiByElement = [String: [NMRNucleus]]()
    var nucleiByName = [String: NMRNucleus]()
    var nucleiBySymbol = [String: [NMRNucleus]]()
    
    // MARK: - Methods
    private init() {
        let table = NMRNucleusTable()
        let nuclei = table.nuclei
        
        for (index, nucleus) in nuclei.enumerated() {
            self.nuclei.append(nucleus)
            nucleiDictionary[nucleus.identifier] = index
            nucleiById[nucleus.id] = nucleus
            nucleiByElement[nucleus.element.lowercased(), default: []].append(nucleus)
            nucleiByName[nucleus.nameNucleus.lowercased()] = nucleus
            nucleiBySymbol[nucleus.symbolNucleus.lowercased(), default: []].append(nucleus)
        }
    }
    
    func nucleus(matching input: String) -> NMRNucleus? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)

        // 1. Exact canonical match
        if let nucleus = nucleiById[trimmed] {
            return nucleus
        }

        // 2. Case-insensitive canonical (e.g. "1h")
        if let nucleus = nucleiById.first(where: { $0.key.lowercased() == trimmed.lowercased() })?.value {
            return nucleus
        }

        // 3. nameNucleus match (e.g. "proton", "deuterium")
        if let nucleus = nucleiByName[trimmed.lowercased()] {
            return nucleus
        }

        // 4. Reverse-format: "H-1", "C-13", "Hydrogen-1" → "1H", "13C"
        let pattern = /^([A-Za-z]+)-?(\d+)$/
        if let match = trimmed.firstMatch(of: pattern) {
            let symbolOrElement = String(match.1)
            let mass = String(match.2)

            // Try exact canonical form: "He-4" → "4He"
            if let nucleus = nucleiById[mass + symbolOrElement] {
                return nucleus
            }

            // Try case-insensitive canonical: "he-4" → "4He"
            let candidateId = (mass + symbolOrElement).lowercased()
            if let nucleus = nucleiById.first(where: { $0.key.lowercased() == candidateId })?.value {
                return nucleus
            }

            // Try symbol lookup (handles multi-char symbols: "He", "Na", "Li"):
            // "He-4" or "he-4" → nucleiBySymbol["he"] → filter by atomicWeight "4"
            if let candidates = nucleiBySymbol[symbolOrElement.lowercased()] {
                if let nucleus = candidates.first(where: { $0.atomicWeight == mass }) {
                    return nucleus
                }
            }

            // Try full element name: "Helium-4", "Sodium-23"
            if let candidates = nucleiByElement[symbolOrElement.lowercased()] {
                if let nucleus = candidates.first(where: { $0.atomicWeight == mass }) {
                    return nucleus
                }
            }
        }

        return nil
    }
    
    func normalizedElementKey(for input: String) -> String {
        let lowercased = input.lowercased()

        // Already a valid element key (e.g. "helium", "carbon")
        if nucleiByElement[lowercased] != nil {
            return lowercased
        }

        // Symbol input (e.g. "He", "he", "NA") — look up via nucleiBySymbol
        if let nucleus = nucleiBySymbol[lowercased]?.first {
            return nucleus.element.lowercased()
        }

        // No match found — return as-is and let the caller handle the nil result
        return lowercased
      }
}
