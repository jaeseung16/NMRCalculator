//
//  UserData.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import Combine
import SwiftUI

final class UserData: ObservableObject {
    @Published var nuclei = NMRPeriodicTable.shared.nuclei
    @Published var scrollAmount = 10.0
    @Published var focus = Focus.ExternalField
    
    static var γProton: Double {
        return NMRPeriodicTable.shared.nuclei[0].γ
    }
    
    enum Focus {
        case ExternalField, ProtonFrequency
    }
}


