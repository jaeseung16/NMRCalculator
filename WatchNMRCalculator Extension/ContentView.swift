//
//  ContentView.swift
//  WatchNMRCalculator Extension
//
//  Created by Jae Seung Lee on 1/12/20.
//  Copyright © 2020 Jae-Seung Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var nucleus: NMRNucleus
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            HStack(alignment: .top) {
                    Text("\(self.nucleus.atomicWeight)")
                        .font(.caption)
                    +
                    Text("\(self.nucleus.symbolNucleus)").font(.title)
            }
            
            HStack(alignment: .top, spacing: 1) {
                Text("Nuclear\nSpin")
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .scaledToFill()

                Spacer()
                Text("\(self.nucleus.nuclearSpin)")
                    .font(.body)

            }.padding()

            HStack(alignment: .top, spacing: 1) {
                Text("γ\n(MHz/T)")
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .scaledToFill()

                Spacer()

                Text("\(self.nucleus.γ)").font(.body).scaledToFit()
            }.padding()

            HStack(alignment: .top, spacing: 1) {
                Text("NA\n(%)")
                    .font(.caption)
                    .scaledToFill()
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Spacer()

                Text("\(self.nucleus.naturalAbundance)")
                    .font(.body)
                    .scaledToFit()

            }.padding()
        }
        .padding()
    }
    
    func buildTextForSymbol(nucleus: NMRNucleus, fontsize: CGFloat) -> NSAttributedString {
        let characterAttributeForWeight = [NSAttributedString.Key.baselineOffset : fontsize as AnyObject,
                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontsize, weight: UIFont.Weight.bold)]
        let textForWeight = NSMutableAttributedString(string: nucleus.atomicWeight)
        textForWeight.setAttributes(characterAttributeForWeight, range: NSMakeRange(0, nucleus.atomicWeight.lengthOfBytes(using: String.Encoding.utf8)) )
        
        let characterAttributeForName = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 2.0 * fontsize, weight: UIFont.Weight.bold)]
        let textForName = NSMutableAttributedString(string: nucleus.symbolNucleus)
        textForName.setAttributes(characterAttributeForName, range: NSMakeRange(0, nucleus.symbolNucleus.lengthOfBytes(using: String.Encoding.utf8)) )
        
        textForWeight.append(textForName)
        return textForWeight
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(nucleus: NMRNucleus())
    }
}
