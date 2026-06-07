//
//  NMRCalculator2Tests.swift
//  NMRCalculator2Tests
//
//  Created by Jae Seung Lee on 9/9/23.
//  Copyright © 2023 Jae-Seung Lee. All rights reserved.
//

import XCTest
@testable import NMRCalculator2

final class NMRCalculator2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testNMRAssistantService() async throws {
        let navigationState = NMRAssistantNavigationState()
        let service = NMRAssistantService(navigationState: navigationState)
        
        await service.send("Which isotopes of carbon are NMR active?")
        
        print("**********")
        service.messages.forEach { print($0) }
        print("**********")
        //XCTAssertTrue(service.messages.isEmpty)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
