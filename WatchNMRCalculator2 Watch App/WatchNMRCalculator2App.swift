//
//  WatchNMRCalculator2App.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/13/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

@main
struct WatchNMRCalculator2_Watch_AppApp: App {
    private let calculator = WatchNMRCalculator2()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calculator)
        }
    }
}
