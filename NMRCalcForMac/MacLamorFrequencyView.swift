//
//  MacLamorFrequencyView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 1/31/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacLamorFrequencyView: View {
    public static let gammaProton = 267.522128 / 2 / Double.pi // in MHz/T
    public static let gammaElectron = -176.0859644 / 2 / Double.pi // in GHz/T
    
    private static let frequencyFormat = "%6.4f"
    
    private let externalFieldFormat = "%.4f"
    private let larmorFrequencyFormat = "%.3f"
    
    @State private var isEditing = false
    @State var larmorFrequency: Double = MacLamorFrequencyView.gammaProton
    @State var externalField: Double
    @State var protonFrequency: Double
    @State var electronFrequency: Double
    
    let proton = NMRNucleus()
    
    @EnvironmentObject var calculator: MacNMRCalculator
    
    var elementSymbol: String {
        return calculator.nucleus?.symbolNucleus ?? proton.symbolNucleus
    }
    
    var atomicWeight: UInt {
        return UInt(calculator.nucleus?.atomicWeight ?? proton.atomicWeight)!
    }
    
    var gyromagneticRatio: Double {
        return Double(calculator.nucleus?.gyromagneticRatio ?? proton.gyromagneticRatio)!
    }
    
    var electronFrquency: Double {
        return self.externalField * MacLamorFrequencyView.gammaElectron
    }
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter
    }
    
    var body: some View {
        VStack {
            WatchAtomicElementView(
                elementSymbol: elementSymbol,
                massNumber: atomicWeight)
                .scaledToFill()
                .foregroundColor(Color.primary)
            
            HStack(alignment: .center) {
                Spacer()
                
                Text("Larmor Frequency")
                    .font(.caption)
                
                Spacer()
                Spacer()
                
                Text("External Field")
                    .font(.caption)
                
                Spacer()
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                TextField("0.0", value: $calculator.larmorFrequency,
                          formatter: numberFormatter) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    _ = calculator.$larmorFrequency.sink() { _ in
                        calculator.larmorFrequencyUpdated()
                    }
                }
                .font(.headline)
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.trailing)
                
                Text(" MHz @ ")
                    .font(.headline)
                TextField("0.0", value: $calculator.externalField,
                          formatter: numberFormatter) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    _ = calculator.$externalField.sink() {
                        let externalField = $0 ?? 1.0
                        if externalField < 0.0 {
                            calculator.externalField = 0.0
                        } else if externalField > 1000.0 {
                            calculator.externalField = 1000.0
                        }
                        calculator.externalFieldUpdated()
                    }
                }
                .multilineTextAlignment(.trailing)
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                .font(.headline)
                Text(" T")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Proton Frequency")
                        .font(.caption)

                    HStack(alignment: .center, spacing: 0) {
                        TextField("0.0", value: $calculator.protonFrequency,
                                  formatter: numberFormatter) { (isEditing) in
                            self.isEditing = isEditing
                        } onCommit: {
                            _ = calculator.$protonFrequency.sink() { _ in
                                calculator.protonFrequencyUpdated()
                            }
                        }
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        .font(.body)
                        Text(" MHz")
                            .font(.body)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Electron Frequency")
                        .font(.caption)

                    HStack(alignment: .center, spacing: 0) {
                        TextField("0.0", value: $calculator.electronFrequency,
                                  formatter: numberFormatter) { isEditing in
                            self.isEditing = isEditing
                        } onCommit: {
                            _ = calculator.$electronFrequency.sink() { _ in
                                calculator.electronFrequencyUpdated()
                            }
                        }
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        .font(.body)
                        Text(" GHz")
                            .font(.body)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct MacLamorFrequencyView_Previews: PreviewProvider {
    @State static var externalField: Double = 1.0
    @State static var larmorFrequency: Double = Double(UserData().nuclei[6].gyromagneticRatio)!
    @StateObject static var calculator = MacNMRCalculator()
    
    static var previews: some View {
        MacLamorFrequencyView(
            larmorFrequency: MacLamorFrequencyView_Previews.larmorFrequency,
            externalField: MacLamorFrequencyView_Previews.externalField,
            protonFrequency: MacLamorFrequencyView.gammaProton * 1.0,
            electronFrequency: MacLamorFrequencyView.gammaElectron * 1.0)
            .environmentObject(calculator)
    }
}
