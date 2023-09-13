//
//  UserData.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import Combine
import SwiftUI

final class NMRPeriodicTableData: ObservableObject {
    @Published var nuclei = NMRPeriodicTable.shared.nuclei
    @Published var scrollAmount = 10.0
    @Published var focus = Focus.ExternalField
    
    static var γProton: Double {
        return NMRPeriodicTable.shared.nuclei[0].γ
    }
    
    enum Focus: Hashable, Equatable {
        case ExternalField, ProtonFrequency
    }
    
    enum Property: String {
        case nuclearSpin = "Nuclear Spin"
        case gyromagneticRatio = "Gyromagnetic Ratio (MHz/T)"
        case naturalAbundance = "Natural Abundance (%)"
        case externalField = "External Field"
        case larmorFrequency = "Larmor Frequency"
        case protonFrequency = "Proton Frequency"
        case electronFrequency = "Electron Frequency"
    }
    
    enum Unit: String {
        case T
        case MHz
        case GHz
    }
}


