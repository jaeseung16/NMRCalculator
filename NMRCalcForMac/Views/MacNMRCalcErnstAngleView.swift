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
                MacNMRCalcItemView(title: "Repetition Time", value: $ernstAngleCalculator.repetitionTime, unit: "sec") {
                    _ = ernstAngleCalculator.$repetitionTime
                        .filter() { $0 != nil }
                        .sink() { _ in
                            ernstAngleCalculator.repetitionTimeUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Relaxation Time", value: $ernstAngleCalculator.relaxationTime, unit: "sec") {
                    _ = ernstAngleCalculator.$relaxationTime
                        .filter() { $0 != nil }
                        .sink() { _ in
                            ernstAngleCalculator.relaxationTimeUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Ernst Angle", value: $ernstAngleCalculator.ernstAngle, unit: "°") {
                    _ = ernstAngleCalculator.$ernstAngle
                        .filter() { $0 != nil }
                        .sink() { _ in
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
