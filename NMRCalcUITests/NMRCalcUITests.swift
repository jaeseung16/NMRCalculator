//
//  NMRCalcUITests.swift
//  NMRCalcUITests
//
//  Created by Jae Seung Lee on 3/16/19.
//  Copyright © 2019 Jae-Seung Lee. All rights reserved.
//

import XCTest

class NMRCalcUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        //app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "1H, Nuclear Spin: 1/2, Gyromagnetic Ratio: 42.6 MHz/T, Natural Abundance: 99.9885 %")
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let tablesQuery = app.tables
        
        // Set the external magnetic field to 1 Tesla
        tablesQuery.cells.containing(.staticText, identifier:"External Magnetic Field (Tesla)").children(matching: .textField).element.tap()
    
        app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let larmorFrequency = "\(tablesQuery.cells.containing(.staticText, identifier:"Larmor Frequency (MHz)").children(matching: .textField).firstMatch.value!)"
        
        // Extract the gyromagnetic raio
        let pickerTitle = "\(app.pickerWheels.firstMatch.value!)"
        let nsRange = NSRange(pickerTitle.startIndex..<pickerTitle.endIndex, in: pickerTitle)
        
        let pattern = "(?<gamma>-*\\d+.\\d+) MHz"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matchRange = regex.firstMatch(in: pickerTitle, options: [], range: nsRange)?.range(withName: "gamma")
        
        let gyromagneticRatio = pickerTitle[Range(matchRange!, in: pickerTitle)!]
        
        XCTAssertEqual(String(format: "%.2g", Double(larmorFrequency)!), String(format: "%.2g", Double(gyromagneticRatio)!))
    }
    
    func testTabBarButtons() {
        let tabBarsQuery = app.tabBars
        
        tabBarsQuery.buttons["Nucleus"].tap()
        XCTAssertTrue(app.navigationBars["Nucleus"].exists)
        
        tabBarsQuery.buttons["Signal"].tap()
        XCTAssertTrue(app.navigationBars["Signal"].exists)
        
        tabBarsQuery.buttons["RF Pulse"].tap()
        XCTAssertTrue(app.navigationBars["RF Pulse"].exists)
        
        tabBarsQuery.buttons["Solution"].tap()
        XCTAssertTrue(app.navigationBars["Solution"].exists)
        
        tabBarsQuery.buttons["Info"].tap()
        XCTAssertTrue(app.navigationBars["Information"].exists)
        
    }

}
