//
//  NMRNucleusTable.swift
//  NMRCalculatorCommon
//
//  Created by Jae Seung Lee on 5/31/26.
//

public struct NMRNucleusTable: Sendable {
    
    public let nuclei: [NMRNucleus]
    
    @MainActor
    public init() {
        let loader = NMRNucleusTableLoader.shared
        nuclei = loader.loaded ? loader.nmrNucleusTable() : [NMRNucleus]()
    }
    
    public init(nuclei: [NMRNucleus]) {
        self.nuclei = nuclei
    }
}
