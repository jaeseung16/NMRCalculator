//
//  NucleusList.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NucleusList<DetailView: View>: View {
    @EnvironmentObject var userData: NMRPeriodicTableData
    
    let detailViewProducer: (NMRNucleus) -> DetailView
    
    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.userData.nuclei, id: \.self) { nucleus in
                    NavigationLink(destination:
                        self.detailViewProducer(nucleus)
                        .environmentObject(self.userData)) {
                            WatchNucleusView(nucleus: nucleus)
                    }
                    .navigationBarTitle("NMR Calculator")
                }
                .frame(width: geometry.size.width * 0.88, height: geometry.size.height * 0.7)
            }
            .listStyle(CarouselListStyle())
        }
    }
}

struct NucleusList_Previews: PreviewProvider {
    static var previews: some View {
        let userData = NMRPeriodicTableData()
        return NucleusList {WatchNucleusView(nucleus: $0)}
            .environmentObject(userData)
    }
}
