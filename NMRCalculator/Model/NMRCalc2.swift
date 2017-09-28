//
//  NMRCalc2.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 9/27/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

class NMRCalc2 {
    // MARK: Properties
    var a: Double
    var b: Double
    var c: Double
    
    enum Variables: String {case a, b, c}
    
    // MARK: Methods
    init() {
        a = 1.0
        b = 1.0
        c = 1.0
    }
    
    init(a: Double, b: Double, c: Double) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    func setParameter(_ name: String, to value: Double) -> Bool {
        guard let option = Variables(rawValue: name) else {
            return false
        }
        
        switch option {
        case .a:
            self.a = value
        case .b:
            self.b = value
        case .c:
            self.c = value
        }
        
        return true
    }
    
    func evaluateParameter(_ name: String) -> Bool {
        guard let option = Variables(rawValue: name) else {
            return false
        }
        
        switch option {
        case .a:
            self.a = self.b * self.c
        case .b:
            if self.a == 0 {
                return false
            }
            self.b = self.c / self.a
        case .c:
            if self.a == 0 {
                return false
            }
            self.c = self.b / self.a
        }
        
        return true
    }
}
