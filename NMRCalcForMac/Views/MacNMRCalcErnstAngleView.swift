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
                    let previousValue = viewModel.repetitionTime
                    viewModel.repetitionTime = repetitionTime
                    if viewModel.validateRepetitionTime() {
                        viewModel.repetitionTimeUpdated()
                        relaxationTime = viewModel.relaxationTime
                        ernstAngle = viewModel.ernstAngle
                    } else {
                        repetitionTime = previousValue
                        viewModel.repetitionTime = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Relaxation Time",
                                   titleFont: .body,
                                   value: $relaxationTime,
                                   unit: NMRCalcUnit.sec,
                                   formatter: relaxationTimeFormatter) {
                    let previousValue = viewModel.relaxationTime
                    viewModel.relaxationTime = relaxationTime
                    if viewModel.validateRelaxationTime() {
                        viewModel.relaxationTimeUpdated()
                        relaxationTime = viewModel.relaxationTime
                        ernstAngle = viewModel.ernstAngle
                    } else {
                        relaxationTime = previousValue
                        viewModel.relaxationTime = previousValue
                        showAlert.toggle()
                    }
                }
                
                MacNMRCalcItemView(title: "Ernst Angle",
                                   titleFont: .body,
                                   value: $ernstAngle,
                                   unit: NMRCalcUnit.degree,
                                   formatter: flipAngleFormatter) {
                    let previousValue = viewModel.ernstAngle
                    viewModel.ernstAngle = ernstAngle
                    if viewModel.validateErnstAngle() {
                        viewModel.ernstAngleUpdated()
                        repetitionTime = viewModel.repetitionTime
                        relaxationTime = viewModel.relaxationTime
                    } else {
                        ernstAngle = previousValue
                        viewModel.ernstAngle = previousValue
                        showAlertErnstAngle.toggle()
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
        .alert(ernstAngleAlertMessage, isPresented: $showAlertErnstAngle) {
            Button("OK") {
                showAlertErnstAngle.toggle()
            }
        }
    }
}
