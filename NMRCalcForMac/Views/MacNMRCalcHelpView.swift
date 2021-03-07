//
//  MacNMRCalcInfoView.swift
//  NMRCalcForMac
//
//  Created by Jae Seung Lee on 3/5/21.
//  Copyright © 2021 Jae-Seung Lee. All rights reserved.
//

import SwiftUI
import PDFKit

struct MacNMRCalcHelpView: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        let pdfView = PDFView()
        if let url = Bundle.main.url(forResource: "NMRCalculatorInfo", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: url)
            pdfView.displayMode = .singlePage
            pdfView.autoScales = true
        }
        return pdfView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}

struct MacNMRCalcInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MacNMRCalcHelpView()
    }
}
