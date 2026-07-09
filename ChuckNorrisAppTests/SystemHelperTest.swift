//
//  SystemHelperTest.swift
//  ChuckNorrisAppTests
//
//  Created by Antigravity on 09/07/26.
//

import XCTest
@testable import ChuckNorrisApp

final class SystemHelperTest: XCTestCase {
    func testGetAppName() {
        let appName = SystemHelper.getAppName()
        XCTAssertFalse(appName.isEmpty)
    }
    
    func testGetAppVersion() {
        let version = SystemHelper.getAppVersion()
        XCTAssertFalse(version.isEmpty)
    }
    
    func testGetAppBuild() {
        let build = SystemHelper.getAppBuild()
        XCTAssertFalse(build.isEmpty)
    }
    
    func testGetFormattedAppVersion() {
        let formatted = SystemHelper.getFormattedAppVersion()
        XCTAssertFalse(formatted.isEmpty)
    }
}
