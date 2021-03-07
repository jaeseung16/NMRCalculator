//
//  MacNucluesInfoView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 2/6/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct MacNucleusInfoView: View {
    var title: String
    var item: String
    
    var body: some View {
        HStack(alignment: .center) {
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

struct MacNucleusInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MacNucleusInfoView(title: "Nuclear Spin", item: "1/2")
    }
}
