//
//  MacNMRCalcPulseView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcPulseView: View {
    @ObservedObject var pulseCalculator = MacNMRPulseCalculator()

    var body: some View {
        VStack {
            Section(header: Text("First Pulse")) {
                MacNMRCalcItemView(title: "Pulse duration", value: $pulseCalculator.duration1, unit: "μs") {
                    _ = pulseCalculator.$duration1.sink() { _ in
                        pulseCalculator.duration1Updated()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $pulseCalculator.flipAngle1, unit: "°") {
                    _ = pulseCalculator.$flipAngle1.sink() { _ in
                        pulseCalculator.flipAngle1Updated()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $pulseCalculator.amplitude1, unit: "Hz") {
                    _ = pulseCalculator.$amplitude1.sink() { _ in
                        pulseCalculator.amplitude1Updated()
                    }
                }
            }
            
            Section(header: Text("Second Pulse")) {
                MacNMRCalcItemView(title: "Pulse duration", value: $pulseCalculator.duration2, unit: "μs") {
                    _ = pulseCalculator.$duration2.sink() { _ in
                        pulseCalculator.duration2Updated()
                    }
                }
                
                MacNMRCalcItemView(title: "Flip angle", value: $pulseCalculator.flipAngle2, unit: "°") {
                    _ = pulseCalculator.$flipAngle2.sink() { _ in
                        pulseCalculator.flipAngle2Updated()
                    }
                }
                
                MacNMRCalcItemView(title: "RF Amplitude", value: $pulseCalculator.amplitude2, unit: "Hz") {
                    _ = pulseCalculator.$amplitude2.sink() { _ in
                        pulseCalculator.amplitude2Updated()
                    }
                }
                
                MacNMRCalcItemView(title: "RF power relateve to 1st", value: $pulseCalculator.relativePower, unit: "dB") {
                    _ = pulseCalculator.$relativePower.sink() { _ in
                        pulseCalculator.relativePowerUpdated()
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
