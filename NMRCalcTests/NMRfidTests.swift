//
//  NMRfidTests.swift
//  NMRCalcTests
//
//  Created by Jae Seung Lee on 12/8/19.
//  Copyright © 2019 Jae-Seung Lee. All rights reserved.
//

import XCTest
@testable import NMRCalculator

class NMRfidTests: XCTestCase {
    var nmrFid: NMRfid!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        nmrFid = NMRfid()
    }

    override func tearDown() {
              // Put teardown code here. This method is called after the invocation of each test method in the class.
              nmrFid = nil
              super.tearDown()
          }

    func testNMRfidSet() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parameter = "size"
        let value = 0.0
        
        let succeed = nmrFid.set(parameter: parameter, to: value)
        
        XCTAssertEqual(succeed, false, "size should be larger than 0")
    }

}
