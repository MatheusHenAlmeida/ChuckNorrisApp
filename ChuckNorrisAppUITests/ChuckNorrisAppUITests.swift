//
//  ChuckNorrisAppUITests.swift
//  ChuckNorrisAppUITests
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import XCTest

final class ChuckNorrisAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testJokeApiIntegration() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.staticTexts["Get a joke"].tap()
        sleep(5)
        let labelView = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == 'JokeLabel'")).firstMatch
        
        XCTAssertNotNil(labelView)
        XCTAssertTrue(!labelView.label.isEmpty)
    }
}
