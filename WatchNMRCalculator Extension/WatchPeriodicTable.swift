//
//  SwiftUIView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI
import Foundation

class WatchPeriodicTable {
    // MARK: - Properties
    static let shared = WatchPeriodicTable()
    var nuclei = [NMRNucleus]()
    var nucleiDictionary = [String: Int]()
    
    // MARK: - Methods
    private init() {
        guard let nucleusTable = readtable() else {
            return
        }
        
        for k in 0..<(nucleusTable.count - 1) {
            let nucleus = NMRNucleus(string: nucleusTable[k])
            print("\(nucleus)")
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
