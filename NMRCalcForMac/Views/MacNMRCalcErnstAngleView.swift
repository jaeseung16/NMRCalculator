//
//  MacNMRErnstAngleView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcErnstAngleView: View {
    @EnvironmentObject var viewModel: MacNMRCalculatorViewModel

    var body: some View {
        VStack {
            Section(header:Text("Ernst Angle").font(.title2)) {
                MacNMRCalcItemView(title: "Repetition Time", value: $viewModel.repetitionTime, unit: "sec") {
                    viewModel.repetitionTimeUpdated()
                }
                
                MacNMRCalcItemView(title: "Relaxation Time", value: $viewModel.relaxationTime, unit: "sec") {
                    viewModel.relaxationTimeUpdated()
                }
                
                MacNMRCalcItemView(title: "Ernst Angle", value: $viewModel.ernstAngle, unit: "°") {
                    viewModel.ernstAngleUpdated()
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
