//
//  WatchAtomicElementView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/18/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchAtomicElementView: View {
    let elementSymbol: String
    let massNumber: UInt
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("\(self.massNumber)")
                .font(.subheadline)
                
            Text(self.elementSymbol)
                .font(.title)
        }
    }
}

struct WatchAtomicElementView_Previews: PreviewProvider {
    static var previews: some View {
        WatchAtomicElementView(elementSymbol: "Mg", massNumber: 24)
    }
}
