//
//  NuclearListView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI
import NMRCalculatorCommon

struct NuclearListView: View {

    @Environment(NMRAssistantNavigationState.self) private var navigationState

    private let nuclei = NMRPeriodicTable.shared.nuclei

    @State private var selected: NMRNucleus.ID?
    @State private var showAssistant = false

    var body: some View {
        NavigationSplitView {
            List(nuclei, selection: $selected) {
                NucleusInfoView(nucleus: $0)
            }
            .listStyle(.plain)
            .navigationTitle("NMR Calculator 2")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAssistant = true
                    } label: {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                    }
                }
            }
            .sheet(isPresented: $showAssistant) {
                NMRAssistantView(navigationState: navigationState)
            }
            .onChange(of: navigationState.requestedNucleusID) { _, newID in
                if let newID {
                    selected = newID
                    showAssistant = false
                }
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
