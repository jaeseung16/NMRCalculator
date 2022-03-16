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
    
    @State private var showAlert = false

    var body: some View {
        VStack {
            Section(header:Text("Ernst Angle").font(.title2)) {
                MacNMRCalcItemView(title: "Repetition Time", value: $viewModel.repetitionTime, unit: "sec") {
                    if viewModel.validateRepetitionTime() {
                        viewModel.repetitionTimeUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Relaxation Time", value: $viewModel.relaxationTime, unit: "sec") {
                    if viewModel.validateRelaxationTime() {
                        viewModel.relaxationTimeUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Ernst Angle", value: $viewModel.ernstAngle, unit: "°") {
                    if viewModel.validateErnstAngle() {
                        viewModel.ernstAngleUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
            }
        }
        .padding()
        .alert("Try another value", isPresented: $showAlert) {
            Button("OK") {
                showAlert.toggle()
            }
        }
    }
}

struct MacNMRErnstAngleView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcErnstAngleView()
    }
}
