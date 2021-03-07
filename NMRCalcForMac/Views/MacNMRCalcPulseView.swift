//
//  MacNMRCalcPulseView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcPulseView: View {
    @ObservedObject var calculator = PulseCalculatorViewModel()

    var body: some View {
        VStack {
            Section(header: Text("First Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration", value: $calculator.duration1, unit: "μs") {
                    _ = calculator.$duration1
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.duration1Updated()
                        }
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $calculator.flipAngle1, unit: "°") {
                    _ = calculator.$flipAngle1
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.flipAngle1Updated()
                        }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $calculator.amplitude1, unit: "Hz") {
                    _ = calculator.$amplitude1
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.amplitude1Updated()
                        }
                }
            }
            
            Section(header: Text("Second Pulse").font(.title2)) {
                MacNMRCalcItemView(title: "Pulse duration", value: $calculator.duration2, unit: "μs") {
                    _ = calculator.$duration2
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.duration2Updated()
                        }
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $calculator.flipAngle2, unit: "°") {
                    _ = calculator.$flipAngle2
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.flipAngle2Updated()
                        }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $calculator.amplitude2, unit: "Hz") {
                    _ = calculator.$amplitude2
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.amplitude2Updated()
                        }
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st", value: $calculator.relativePower, unit: "dB") {
                    _ = calculator.$relativePower
                        .filter() { $0 != nil }
                        .sink() { _ in
                            calculator.relativePowerUpdated()
                        }
                }
            }
        }
        .padding()
    }
    
}

struct MacNMRCalcPulseView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcPulseView()
    }
}
