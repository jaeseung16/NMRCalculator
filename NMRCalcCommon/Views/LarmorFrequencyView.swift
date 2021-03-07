//
//  LarmorFrequencyView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/26/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct LarmorFrequencyView: View {
    var externalField: Double
    var gyromatneticRatio: Double
    
    private let externalFieldFormat = "%.4f"
    private let larmorFrequencyFormat = "%.3f"
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .top) {
                Text(String(format: externalFieldFormat, self.externalField * self.gyromatneticRatio))
                    .font(.headline)
                +
                Text(" MHz  ")
                    .font(.body)
            }
            
            HStack(alignment: .top, spacing: 0) {
                Text("@ ")
                Text(String(format: larmorFrequencyFormat, Double(self.externalField)))
                    .font(.headline)
                Text(" T")
                    .font(.body)
            }
        }
    }
}

struct LarmorFrequencyView_Previews: PreviewProvider {
    static var previews: some View {
        LarmorFrequencyView(externalField: 1.0, gyromatneticRatio: 42.56)
    }
}
