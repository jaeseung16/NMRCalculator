//
//  NMRCalcTests.swift
//  NMRCalcTests
//
//  Created by Jae Seung Lee on 12/8/19.
//  Copyright © 2019 Jae-Seung Lee. All rights reserved.
//

import XCTest
@testable import NMRCalculator

class NMRCalcTests: XCTestCase {
    var nmrCalc: NMRCalc!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        nmrCalc = NMRCalc()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        nmrCalc = nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
