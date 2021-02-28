//
//  MacNMRErnstAngleView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcErnstAngleView: View {
    @ObservedObject var ernstAngleCalculator = MacNMRErnstAngleCalculator()

    var body: some View {
        VStack {
            Section(header: Text("Ernst Angle")) {
                MacSignalItemView(title: "Repetition Time", value: $ernstAngleCalculator.repetitionTime, unit: "sec") {
                    _ = ernstAngleCalculator.$repetitionTime.sink() { _ in
                        ernstAngleCalculator.repetitionTimeUpdated()
                    }
                }
                
                MacSignalItemView(title: "Relaxatio Time", value: $ernstAngleCalculator.relaxationTime, unit: "sec") {
                    _ = ernstAngleCalculator.$relaxationTime.sink() { _ in
                        ernstAngleCalculator.relaxationTimeUpdated()
                    }
                }
                
                MacSignalItemView(title: "Ernst Angle", value: $ernstAngleCalculator.ernstAngle, unit: "°") {
                    _ = ernstAngleCalculator.$ernstAngle.sink() { _ in
                        ernstAngleCalculator.ernstAngleUpdated()
                    }
                }
            }
        }
        .padding()
    }
}

struct MacNMRErnstAngleView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcErnstAngleView()
    }
}
