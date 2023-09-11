//
//  NuclearListView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NuclearListView: View {
    
    private let nuclei = NMRPeriodicTable.shared.nuclei
    
    @State private var selected: NMRNucleus.ID?
    
    var body: some View {
        NavigationSplitView {
            List(nuclei, selection: $selected) {
                NucleusView(nucleus: $0)
            }
        } detail: {
            if let selected, let nucleus = NMRPeriodicTable.shared.nucleiById[selected] {
                NucleusDetailView(nucleus: nucleus)
                    .environmentObject(NMRCalculator2(nucleus: nucleus))
                    .id(selected)
            }
        }
    }
}
