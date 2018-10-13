//
//  NMRCalculatorTests.swift
//  NMRCalculatorTests
//
//  Created by Jae-Seung Lee on 6/8/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import XCTest
@testable import NMRCalculator

class NMRCalculatorTests: XCTestCase {
    
    var nmrCalcUnderTest: NMRCalc!
    var nucleus: NMRNucleus!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        nucleus = NMRNucleus()
        nmrCalcUnderTest = NMRCalc(nucleus: nucleus)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        nmrCalcUnderTest = nil
        nucleus = nil
        super.tearDown()
    }
    
    func testCalculateDB() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let amp1 = 10000.0
        let amp2 = 100.0
        
        let pulse1 = NMRPulse()
        let pulse2 = NMRPulse()
        
        nmrCalcUnderTest.pulseNMR.append(pulse1)
        nmrCalcUnderTest.pulseNMR.append(pulse2)
        
        let _ = nmrCalcUnderTest.setParameter("amplitude", in: "pulse1", to: amp1)
        let _ = nmrCalcUnderTest.setParameter("amplitude", in: "pulse2", to: amp2)
        let _ = nmrCalcUnderTest.calculate_dB()
        
        XCTAssertEqual(nmrCalcUnderTest.relativepower, -40.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
