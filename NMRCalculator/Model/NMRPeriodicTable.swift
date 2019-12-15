//
//  NMRNucleiTable.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 8/19/18.
//  Copyright © 2018 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRPeriodicTable {
    // MARK: - Properties
    static let shared = NMRPeriodicTable()
    var nuclei = [NMRNucleus]()
    var nucleiDictionary = [String: Int]()
    
    // MARK: - Methods
    private init() {
        guard let nucleusTable = readtable() else {
            return
        }
        
        for k in 0..<(nucleusTable.count - 1) {
            let nucleus = NMRNucleus(fromString: nucleusTable[k])
            nuclei.append(nucleus)
            nucleiDictionary[nucleus.identifier] = k
        }
    }
    
    private func readtable() -> [String]? {
        if let path = Bundle.main.path(forResource: "NMRFreqTable", ofType: "txt") {
            do {
                let table = try String(contentsOfFile: path, encoding: String.Encoding.utf8).components(separatedBy: "\n")
                return table
            } catch {
                print("Error: Cannot read the table.")
                return nil
            }
        }
        return nil
    }
}
