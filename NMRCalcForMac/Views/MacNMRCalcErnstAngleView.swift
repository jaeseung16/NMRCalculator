//
//  MacNMRErnstAngleView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcErnstAngleView: View {
    @ObservedObject var calculator = ErnstAngleCalculatorViewModel()

    var body: some View {
        VStack {
            Section(header: Text("Ernst Angle")) {
                MacNMRCalcItemView(title: "Repetition Time", value: $calculator.repetitionTime, unit: "sec") {
                    _ = calculator.$repetitionTime
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.repetitionTimeUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Relaxation Time", value: $calculator.relaxationTime, unit: "sec") {
                    _ = calculator.$relaxationTime
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.relaxationTimeUpdated()
                        }
                }
                
                MacNMRCalcItemView(title: "Ernst Angle", value: $calculator.ernstAngle, unit: "°") {
                    _ = calculator.$ernstAngle
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.ernstAngleUpdated()
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
