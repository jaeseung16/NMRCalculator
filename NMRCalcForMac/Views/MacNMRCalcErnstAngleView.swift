//
//  MacNMRErnstAngleView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/28/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNMRCalcErnstAngleView: View {
    @EnvironmentObject private var viewModel: MacNMRCalculatorViewModel
    
    @State var repetitionTime: Double
    @State var relaxationTime: Double
    @State var ernstAngle: Double
    
    @State private var showAlert = false
    @State private var showAlertErnstAngle = false
    
    private let alertMessage = "Try a positive value."
    private let ernstAngleAlertMessage = "Try a value between 0 and 90 exclusive"
    
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
                                   value: $repetitionTime,
                                   unit: NMRCalcUnit.sec,
                                   formatter: relaxationTimeFormatter) {
                    if viewModel.isNonNegative(repetitionTime) {
                        viewModel.update(.repetitionTime, to: repetitionTime)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Relaxation Time",
                                   titleFont: .body,
                                   value: $relaxationTime,
                                   unit: NMRCalcUnit.sec,
                                   formatter: relaxationTimeFormatter) {
                    if viewModel.isPositive(relaxationTime) {
                        viewModel.update(.relaxationTime, to: relaxationTime)
                    } else {
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Ernst Angle",
                                   titleFont: .body,
                                   value: $ernstAngle,
                                   unit: NMRCalcUnit.degree,
                                   formatter: flipAngleFormatter) {
                    if viewModel.validate(ernstAngle: ernstAngle) {
                        viewModel.update(.ernstAngle, to: ernstAngle)
                    } else {
                        showAlertErnstAngle.toggle()
                    }
                }
            }
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                reset()
                showAlert.toggle()
            }
        }
        .alert(ernstAngleAlertMessage, isPresented: $showAlertErnstAngle) {
            Button("OK") {
                reset()
                showAlertErnstAngle.toggle()
            }
        }
        .onReceive(viewModel.$ernstAngleUpdated) { _ in
            reset()
        }
    }
    
    private func reset() {
        repetitionTime = viewModel.repetitionTime
        relaxationTime = viewModel.relaxationTime
        ernstAngle = viewModel.ernstAngle
    }
}
