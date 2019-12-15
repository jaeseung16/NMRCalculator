//
//  NMRLarmorTests.swift
//  NMRCalcTests
//
//  Created by Jae Seung Lee on 12/15/19.
//  Copyright © 2019 Jae-Seung Lee. All rights reserved.
//

import XCTest
@testable import NMRCalculator

class NMRLarmorTests: XCTestCase {
    var nmrLarmor: NMRLarmor!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        nmrLarmor = NMRLarmor()
        print(nmrLarmor.describe())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        nmrLarmor = nil
        super.tearDown()
    }

    func testNMRLarmorSetExternalFieldAndUpdate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parameterToSet = NMRLarmor.Parameter.field
        let externalField = -1.0
        
        let parameterToUpdate = NMRLarmor.Parameter.larmor
        
        let succeedToSet = nmrLarmor.set(parameter: parameterToSet, to: externalField)
        XCTAssertEqual(succeedToSet, true, "Field can be any number in tesla")
        
        let succeedToUpdate = nmrLarmor.update(parameter: parameterToUpdate)
        XCTAssertEqual(succeedToUpdate, true, "Larmor frequency should be updated")
        
        XCTAssertEqual(nmrLarmor.frequencyLarmor, externalField * nmrLarmor.nucleus.γ)
    }
    
    func testNMRLarmorSetProtonFrequencyAndUpdate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parameterToSet = NMRLarmor.Parameter.proton
        let protonFrequency = 500.0
        
        let parameterToUpdate = NMRLarmor.Parameter.larmor
        
        let succeedToSet = nmrLarmor.set(parameter: parameterToSet, to: protonFrequency)
        XCTAssertEqual(succeedToSet, true, "Proton frequency can be any number in MHz")
        
        let succeedToUpdate = nmrLarmor.update(parameter: parameterToUpdate)
        XCTAssertEqual(succeedToUpdate, true, "Larmor frequency should be updated")
        
        XCTAssertEqual(nmrLarmor.frequencyLarmor, protonFrequency / NMRLarmor.gammaProton * nmrLarmor.nucleus.γ)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
