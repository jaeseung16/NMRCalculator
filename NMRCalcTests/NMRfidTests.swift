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

    func testSetSize() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parameter = "size"
        let value = 0.0
        
        let succeed = nmrFid.set(parameter: parameter, to: value)
        
        XCTAssertEqual(succeed, false, "size should be larger than 0")
    }
    
    func testSetDuration() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parameter = "duration"
        let value = 0.0
        
        let succeed = nmrFid.set(parameter: parameter, to: value)
        
        XCTAssertEqual(succeed, false, "duration should be larger than 0")
    }
    
    func testSetDwell() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parameter = "dwell"
        let value = 0.0
        
        let succeed = nmrFid.set(parameter: parameter, to: value)
        
        XCTAssertEqual(succeed, false, "dwell should be larger than 0")
    }
    
    func testUpdateSize() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let oldSize = nmrFid.size
        
        setDuration()
        setDwell()
        
        let sizeParamter = "size"
        nmrFid.update(parameter: sizeParamter)
        let newSize = nmrFid.size
        
        XCTAssertEqual(oldSize, newSize)
    }
    
    func testUpdateDuration() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let oldDuration = nmrFid.duration
        
        setDwell()
        setSize()
        
        let durationParamter = "duration"
        nmrFid.update(parameter: durationParamter)
        let newDuration = nmrFid.duration
        
        XCTAssertEqual(4.0 * oldDuration, newDuration)
    }
    
    func testUpdateDwell() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let oldDwell = nmrFid.dwell
        
        setSize()
        setDuration()
    
        let dwellParamter = "dwell"
        nmrFid.update(parameter: dwellParamter)
        let newDwell = nmrFid.dwell
        
        XCTAssertEqual(oldDwell, newDwell)
    }
    
    private func setDuration() {
        let durationParameter = "duration"
        let newDuration = 2.0 * nmrFid.duration
        nmrFid.set(parameter: durationParameter, to: newDuration)
    }
    
    private func setDwell() {
        let dwellParameter = "dwell"
        let newDwell = 2.0 * nmrFid.dwell
        nmrFid.set(parameter: dwellParameter, to: newDwell)
    }
    
    private func setSize() {
        let sizeParameter = "size"
        let newSize = 2.0 * Double(nmrFid.size)
        nmrFid.set(parameter: sizeParameter, to: newSize)
    }

}
