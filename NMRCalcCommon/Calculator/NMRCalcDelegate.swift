//
//  ParameterConverting.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 7/11/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

public protocol NMRCalcDelegate {
    func process(_ request: NMRCalcRequest) -> Result<NMRCalcResponse, NMRCalcError>
}
