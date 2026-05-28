//
//  NMRCalculator2App.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

@main
struct NMRCalculator2App: App {
    @State private var navigationState = NMRAssistantNavigationState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationState)
        }
    }
}
