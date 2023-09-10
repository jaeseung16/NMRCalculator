//
//  NucleusDetailView.swift
//  NMRCalculator2
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NucleusDetailView: View {
    @EnvironmentObject private var calculator: NMRCalculator2
    
    var nucleus: NMRNucleus
    
    private var proton: NMRNucleus {
        return NMRPeriodicTable.shared.proton
    }
    
    private var elementSymbol: String {
        return nucleus.symbolNucleus
    }
    
    private var atomicWeight: UInt {
        return UInt(nucleus.atomicWeight)!
    }
    
    private var gyromagneticRatio: Double {
        return Double(nucleus.gyromagneticRatio)!
    }
    
    private var nuclearSpin: String {
        return nucleus.nuclearSpin
    }
    
    private var naturalAbundance: String {
        return nucleus.naturalAbundance
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                AtomicElementView(elementSymbol: nucleus.symbolNucleus,
                                  massNumber: UInt(nucleus.atomicWeight)!)
                displayInfo()
                    .frame(minWidth: 0.5 * geometry.size.width, maxWidth: 0.8 * geometry.size.width, alignment: .center)
                
                Spacer()
                
                ScrollView {
                    VStack {
                        Section(header: Text("Larmor Frequencies")) {
                            NMRCalculatorSectionView(calculatorItems: calculator.larmorFrequencies)
                            .environmentObject(calculator)
                        }
                        
                        Section(header: Text("Time Domain")) {
                            TimeDomainView(numberOfTimeDataPoints: calculator.numberOfTimeDataPoints,
                                           acquisitionDuration: calculator.acquisitionDuration,
                                           dwellTime: calculator.dwellTime)
                            .environmentObject(calculator)
                        }
                        
                        Section(header: Text("Frequency Domain")) {
                            FrequencyDomainView(numberOfFrequencyDataPoints: calculator.numberOfFrequencyDataPoints,
                                                spectralWidth: calculator.spectralWidth,
                                                frequencyResolution: calculator.frequencyResolution)
                            .environmentObject(calculator)
                        }
                        
                        Section(header: Text("Pulse 1")) {
                            Pulse1View(duration1: calculator.duration1,
                                      flipAngle1: calculator.flipAngle1,
                                      amplitude1: calculator.amplitude1,
                                      amplitude1InT: calculator.amplitude1InT)
                            .environmentObject(calculator)
                        }
                        
                        Section(header: Text("Pulse 2")) {
                            Pulse2View(duration2: calculator.duration2,
                                      flipAngle2: calculator.flipAngle2,
                                      amplitude2: calculator.amplitude2,
                                      relativePower: calculator.relativePower)
                            .environmentObject(calculator)
                        }
                        
                        Section(header: Text("Ernst Angle")) {
                            NMRCalculatorSectionView(calculatorItems: calculator.ernstAngles)
                            .environmentObject(calculator)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
    
    private func displayInfo() -> some View {
        VStack {
            getInfoView(title: .nuclearSpin,
                        value: Fraction(from: nuclearSpin, isPositive: gyromagneticRatio > 0).inlineDescription)
            
            getInfoView(title: .gyromagneticRatio,
                        value: "\(String(format: "%.6f", abs(gyromagneticRatio)))")
            
            getInfoView(title: .naturalAbundance,
                        value: "\(naturalAbundance)")
        }
    }
    
    private func getInfoView(title: NMRPeriodicTableData.Property, value: String) -> some View {
        HStack(alignment: .center) {
            Text(title.rawValue)
                .font(.callout)
                .foregroundColor(Color.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(Color.primary)
                .fontWeight(.semibold)
        }
    }
}
