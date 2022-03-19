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
    
    private var alertMessage = "Try a positive value."
    
    private var flipAngleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    private var relaxationTimeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        VStack {
            Section(header:Text("Ernst Angle").font(.title2)) {
                MacNMRCalcItemView(title: "Repetition Time",
                                   titleFont: .body,
                                   value: $viewModel.repetitionTime,
                                   unit: "sec",
                                   formatter: relaxationTimeFormatter) {
                    if viewModel.validateRepetitionTime() {
                        viewModel.repetitionTimeUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Relaxation Time",
                                   titleFont: .body,
                                   value: $viewModel.relaxationTime,
                                   unit: "sec",
                                   formatter: relaxationTimeFormatter) {
                    if viewModel.validateRelaxationTime() {
                        viewModel.relaxationTimeUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Ernst Angle",
                                   titleFont: .body,
                                   value: $viewModel.ernstAngle,
                                   unit: "°",
                                   formatter: flipAngleFormatter) {
                    if viewModel.validateErnstAngle() {
                        viewModel.ernstAngleUpdated()
                    } else {
                        showAlert.toggle()
                    }
                }
            }
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
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
