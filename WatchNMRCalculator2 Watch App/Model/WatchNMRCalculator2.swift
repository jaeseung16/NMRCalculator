//
//  WatchNMRCalculator2.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/17/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import Foundation
import Combine

@MainActor
class WatchNMRCalculator2: ObservableObject {
    @Published var nuclei = NMRPeriodicTable.shared.nuclei
    @Published var scrollAmount = 10.0
    @Published var focus = Focus.ExternalField
    
    static var γProton: Double {
        return NMRPeriodicTable.shared.nuclei[0].γ
    }
    
}
