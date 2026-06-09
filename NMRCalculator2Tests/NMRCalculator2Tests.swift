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
        
        /*
         Questions:
         Which isotopes of Carbon are NMR active?
         Which isotopes of Hydrogen are NMR active?
         Which isotopes of N are NMR active?
         What is the resonance frequency of C-13 when the proton NMR frequency is 600 MHz?
         What is the magnetic field when N-15 NMR frequency is 100 MHz?
         What is the gyromagnetic ratio of N-15?
         What is the NMR frequency of N15 at 24T?
         What is the gyromagnetic ratio of sodium nuclei?
         What is the NMR frequency of sodium when the proton frequency is 500 MHz?
         What is the magnetic field when the sodium NMR frequency is 100 MHz?
         What would be the spectral widht when the number of data points is 1024 and the frequency resolution is 1 HZ?
         What is the duration of a 90-degree pulse when the RF ampliotude is 1 kHz?
         What it the duration of a 10-microsecond 90-deg pulse?
         What is the RF amplitude of 10-microsecond 90-deg pulse?
         */
        
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
