//
//  ProtonFrequencyView.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 1/26/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct ProtonFrequencyView: View {
    var protonFrquency: Double
    private let frequencyFormat = "%6.4f"
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("Proton")
                .font(.caption)

            HStack(alignment: .center, spacing: 0) {
                Text(String(format: frequencyFormat, protonFrquency))
                    .font(.headline)
                Text(" MHz")
                    .font(.body)
            }
        }
    }
}

struct ProtonFrequencyView_Previews: PreviewProvider {
    static var previews: some View {
        ProtonFrequencyView(protonFrquency: 42.0)
    }
}
