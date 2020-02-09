//
//  WatchNucleusInfoView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 2/8/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct WatchNucleusInfoView: View {
    var title: String
    var item: String
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(Color.secondary)
            
            Text(item)
            .font(.body)
            .foregroundColor(Color.primary)
        }
    }
}

struct WatchNucleusInfoView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNucleusInfoView(title: "MHz/T", item: "100.0")
    }
}
