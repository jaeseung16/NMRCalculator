//
//  WatchNucleusDetailView.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/13/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusDetailView: View {
    @EnvironmentObject var userData: NMRPeriodicTableData
    
    @FocusState private var focusedLarmorFrequency: Bool
    @FocusState private var focusedProtonFrequency: Bool
    @FocusState private var focus: NMRPeriodicTableData.Focus?
    @State var scrollAmountToFieldFactor: Double = 1
    
    var nucleus: NMRNucleus
    
    private var externalField: Double {
        return userData.focus == .ExternalField ? userData.scrollAmount  : userData.scrollAmount / NMRPeriodicTableData.γProton
    }
    private var protonFrequency: Double {
        return userData.focus == .ProtonFrequency ? userData.scrollAmount : userData.scrollAmount * NMRPeriodicTableData.γProton
    }
    
    private let minValue = 0.0
    private var maxValue: Double {
        return self.userData.focus == .ExternalField ? 100 : 2000
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .trailing, spacing: 0) {
                HStack(alignment: .center) {
                    AtomicElementView(
                        elementSymbol: nucleus.symbolNucleus,
                        massNumber: UInt(nucleus.atomicWeight)!)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        NuclearSpinView(nucleus: nucleus)
                            .font(.body)
                                              
                        Text("\(nucleus.naturalAbundance)")
                            .font(.body)
                    }
                    .padding(.trailing, 8)
                }
                .foregroundColor(.green)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                
                //LarmorFrequencyView(externalField: externalField, gyromatneticRatio: nucleus.γ)
                    //.foregroundColor(focus == .ProtonFrequency ? .secondary : .primary)
                    //.focusable(true) { _ in
                    //    if (userData.focus == .ProtonFrequency) {
                    //        userData.focus = .ExternalField
                    //        userData.scrollAmount /= NMRPeriodicTableData.γProton
                    //    }
                    //}
                    //.frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                    //.focused($focus, equals: .ExternalField)
                    //.focused($focusedLarmorFrequency)
                VStack(alignment: .trailing, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(String(format: "%.4f", externalField * nucleus.γ))
                            .font(.headline)
                        +
                        Text(" MHz  ")
                            .font(.body)
                    }
                    
                    HStack(alignment: .top, spacing: 0) {
                        Text("@ ")
                        Text(String(format: "%.3f", Double(externalField)))
                            .font(.headline)
                        Text(" T")
                            .font(.body)
                    }
                }
                .foregroundColor(userData.focus == .ProtonFrequency ? .secondary : .primary)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                .focusable(true) { _ in
                    if (userData.focus == .ProtonFrequency) {
                        userData.focus = .ExternalField
                        userData.scrollAmount /= NMRPeriodicTableData.γProton
                    }
                }
                
                //ProtonFrequencyView(protonFrquency: protonFrequency)
                    //.foregroundColor(focus == .ProtonFrequency ? .primary : .secondary)
                    //.focusable(true) { _ in
                    //    if (userData.focus == .ExternalField) {
                    //        userData.focus = .ProtonFrequency
                    //        userData.scrollAmount *= NMRPeriodicTableData.γProton
                    //   }
                    //}
                    //.frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                    //.focused($focus, equals: .ProtonFrequency)
                    //.focused($focusedProtonFrequency)
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Proton")
                        .font(.caption)

                    HStack(alignment: .center, spacing: 0) {
                        Text(String(format: "%6.4f", protonFrequency))
                            .font(.headline)
                        Text(" MHz")
                            .font(.body)
                    }
                }
                .foregroundColor(userData.focus == .ProtonFrequency ? .primary : .secondary)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.33)
                .focusable(true) { _ in
                    if (userData.focus == .ExternalField) {
                        userData.focus = .ProtonFrequency
                        userData.scrollAmount *= NMRPeriodicTableData.γProton
                   }
                }
            }
            .digitalCrownRotation($userData.scrollAmount, from: minValue, through: maxValue, by: 0.01, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focus = .ExternalField
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                focus = .ProtonFrequency
            }
        }
        .onChange(of: focusedLarmorFrequency) { _ in
            print("focusedLarmorFrequency=\(focusedLarmorFrequency)")
            if focusedLarmorFrequency {
                userData.focus = .ExternalField
                userData.scrollAmount /= NMRPeriodicTableData.γProton
            }
        }
        .onChange(of: focusedLarmorFrequency) { _ in
            print("focusedLarmorFrequency=\(focusedLarmorFrequency)")
            if focusedProtonFrequency {
                userData.focus = .ProtonFrequency
                userData.scrollAmount *= NMRPeriodicTableData.γProton
            }
        }
        .onChange(of: focus) { _ in
            print("focus=\(String(describing: focus))")
            switch focus {
            case .ExternalField:
                userData.focus = .ExternalField
                userData.scrollAmount /= NMRPeriodicTableData.γProton
            case .ProtonFrequency:
                userData.focus = .ProtonFrequency
                userData.scrollAmount *= NMRPeriodicTableData.γProton
            default:
                userData.focus = .ExternalField
                userData.scrollAmount /= NMRPeriodicTableData.γProton
            }
            
        }
    }

}
