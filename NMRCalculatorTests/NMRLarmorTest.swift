//
//  NMRLarmorTest.swift
//  NMRCalculatorTests
//
//  Created by Jae Seung Lee on 3/16/19.
//  Copyright © 2019 Jae-Seung Lee. All rights reserved.
//

import XCTest
@testable import NMRCalculator

class NMRLarmorTest: XCTestCase {
    
    var nmrLarmor: NMRLarmor!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        nmrLarmor = NMRLarmor()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        nmrLarmor = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(nmrLarmor.nucleus.identifier, "1H")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
