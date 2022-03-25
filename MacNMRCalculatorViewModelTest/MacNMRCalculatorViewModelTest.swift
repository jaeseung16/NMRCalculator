//
//  MacNMRCalculatorViewModelTest.swift
//  MacNMRCalculatorViewModelTest
//
//  Created by Jae Seung Lee on 3/25/22.
//  Copyright © 2022 Jae-Seung Lee. All rights reserved.
//

import XCTest

class MacNMRCalculatorViewModelTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIsPositive() throws {
        let viewModel = MacNMRCalculatorViewModel()
        
        let duration = 0.1
        XCTAssertTrue(viewModel.isPositive(duration))
        
        let flipAngle = 0.0
        XCTAssertFalse(viewModel.isPositive(flipAngle))
        
        let amplitude = -1.0
        XCTAssertFalse(viewModel.isPositive(amplitude))
    }
    
    func testIsNonNegative() throws {
        let viewModel = MacNMRCalculatorViewModel()
        
        let repetitionTime1 = 1.0
        XCTAssertTrue(viewModel.isNonNegative(repetitionTime1))
        
        let repetitionTime2 = 0.0
        XCTAssertTrue(viewModel.isNonNegative(repetitionTime2))
        
        let repetitionTime3 = -1.0
        XCTAssertFalse(viewModel.isNonNegative(repetitionTime3))
    }
    
    func testValidateExternalField() throws {
        let viewModel = MacNMRCalculatorViewModel()
        
        let B0 = 10.0
        XCTAssertTrue(viewModel.validate(externalField: B0))
        
        let largeB0 = 1001.0
        XCTAssertFalse(viewModel.validate(externalField: largeB0))
        
        let negativeB0 = -10.0
        XCTAssertTrue(viewModel.validate(externalField: negativeB0))
        
        let negativelyLargeB0 = -1000.1
        XCTAssertFalse(viewModel.validate(externalField: negativelyLargeB0))
    }
    
    func testValidateNumberOfDataPorints() throws {
        let viewModel = MacNMRCalculatorViewModel()
        
        let numberOfDataPoints1 = 1.0
        XCTAssertTrue(viewModel.validate(numberOfDataPoints: numberOfDataPoints1))
        
        let numberOfDataPoints2 = 0.0
        XCTAssertFalse(viewModel.validate(numberOfDataPoints: numberOfDataPoints2))
    }
    
    func testValidateErnstAngle() throws {
        let viewModel = MacNMRCalculatorViewModel()
        
        let validErnstAngle = 1.0
        XCTAssertTrue(viewModel.validate(ernstAngle: validErnstAngle))
        
        let invalidErnstAngle1 = -10.0
        XCTAssertFalse(viewModel.validate(ernstAngle: invalidErnstAngle1))
        
        let invalidErnstAngle2 = 90.0
        XCTAssertFalse(viewModel.validate(ernstAngle: invalidErnstAngle2))
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
