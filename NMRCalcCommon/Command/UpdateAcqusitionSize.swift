//
//  UpdateAcqusitionSize.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/9/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

class UpdateAcquisitionSize: NMRCalcCommand {
    let dwellAcquisitionTimeConverter: DwellAcquisitionTimeConverter
    
    init(_ dwellAcquisitionTimeConverter: DwellAcquisitionTimeConverter) {
        self.dwellAcquisitionTimeConverter = dwellAcquisitionTimeConverter
    }
    
    func execute(with value: Double) {
        dwellAcquisitionTimeConverter.set(numberOfPoints: Int(value))
    }
}
