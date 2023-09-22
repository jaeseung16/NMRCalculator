//
//  NMRCalcCommand.swift
//  NMRCalculator
//
//  Created by Jae Seung Lee on 12/5/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import Foundation

protocol NMRCalcCommand {
    func execute(with value: Double) -> Void
}
