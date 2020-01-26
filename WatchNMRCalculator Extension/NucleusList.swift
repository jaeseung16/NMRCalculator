//
//  NucleusList.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct NucleusList<DetailView: View>: View {
    @EnvironmentObject var userData: UserData
    
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
                }
                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.6)
            }
            .listStyle(CarouselListStyle())
        }
    }
}

struct NucleusList_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        return NucleusList {WatchNucleusView(nucleus: $0)}
            .environmentObject(userData)
    }
}


extension View {
    func PrintData(nucleus: NMRNucleus) -> some View {
        print("\(nucleus.atomicWeight)\t\(nucleus.symbolNucleus)\t\(nucleus.nuclearSpin)\t\(nucleus.γ)\t\(nucleus.naturalAbundance)")
        return EmptyView()
    }
}
