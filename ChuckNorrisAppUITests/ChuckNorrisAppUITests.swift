//
//  ChuckNorrisAppUITests.swift
//  ChuckNorrisAppUITests
//
//  Created by Antigravity on 09/07/26.
//

import XCTest

final class ChuckNorrisAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppFullFlowAndNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Test Requesting a Joke
        let askButton = app.buttons["ask_joke_button"]
        XCTAssertTrue(askButton.exists, "The 'Ask for Joke' button should exist.")
        askButton.tap()
        
        // Wait up to 5 seconds for the joke text to load or error to display
        let jokeLabel = app.staticTexts["joke_label"]
        XCTAssertTrue(jokeLabel.waitForExistence(timeout: 5.0), "The joke label should exist.")
        XCTAssertFalse(jokeLabel.label.isEmpty, "The joke label text should not be empty.")
        
        // 2. Test Side Menu Navigation to About View
        let menuButton = app.buttons["menu_button"]
        XCTAssertTrue(menuButton.exists, "The Hamburger menu button should exist.")
        menuButton.tap()
        
        let aboutMenuButton = app.buttons["menu_about_button"]
        XCTAssertTrue(aboutMenuButton.waitForExistence(timeout: 2.0), "The 'About' menu item should appear.")
        aboutMenuButton.tap()
        
        // 3. Test About View Components
        let aboutAppName = app.staticTexts["about_app_name"]
        XCTAssertTrue(aboutAppName.waitForExistence(timeout: 2.0), "The App Name on the About screen should exist.")
        XCTAssertFalse(aboutAppName.label.isEmpty)
        
        let aboutAppVersion = app.staticTexts["about_app_version"]
        XCTAssertTrue(aboutAppVersion.exists, "The version label on the About screen should exist.")
        XCTAssertFalse(aboutAppVersion.label.isEmpty)
        
        let aboutCloseButton = app.buttons["about_close_button"]
        XCTAssertTrue(aboutCloseButton.exists, "The close button on the About screen should exist.")
        aboutCloseButton.tap()
        
        // 4. Test Side Menu Navigation to Alarm List
        menuButton.tap()
        
        let manageAlarmsButton = app.buttons["menu_manage_alarms_button"]
        XCTAssertTrue(manageAlarmsButton.waitForExistence(timeout: 2.0), "The 'Manage alarms' menu item should appear.")
        manageAlarmsButton.tap()
        
        // 5. Test Alarm List Add Flow
        let addAlarmButton = app.buttons["alarm_list_add_button"]
        XCTAssertTrue(addAlarmButton.waitForExistence(timeout: 2.0), "The add alarm button should exist on the list.")
        addAlarmButton.tap()
        
        // 6. Test Alarm Edit Sheet Dismissal
        let cancelEditButton = app.buttons["alarm_edit_cancel_button"]
        XCTAssertTrue(cancelEditButton.waitForExistence(timeout: 2.0), "The cancel button on the edit alarm sheet should exist.")
        cancelEditButton.tap()
        
        // 7. Test Closing Alarm List
        let closeAlarmListButton = app.buttons["alarm_list_close_button"]
        XCTAssertTrue(closeAlarmListButton.exists, "The close button on the alarm list should exist.")
        closeAlarmListButton.tap()
    }
}
