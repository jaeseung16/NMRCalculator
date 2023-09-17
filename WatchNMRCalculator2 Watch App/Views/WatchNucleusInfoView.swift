//
//  WatchNucleusInfoView.swift
//  WatchNMRCalculator2 Watch App
//
//  Created by Jae Seung Lee on 9/17/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
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

