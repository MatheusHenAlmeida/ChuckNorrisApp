//
//  SplashViewModelTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 23/07/26.
//

import XCTest
@testable import ChuckNorrisApp

final class MockFeatureFlagsService: FeatureFlagsServiceType {
    var startCalled = false
    var shouldFail = false
    
    func start() async {
        startCalled = true
    }
    
    func getJokesURL() -> String {
        return "https://api.chucknorris.io/jokes"
    }
}

final class SplashViewModelTest: XCTestCase {
    
    @MainActor
    func test_loadRemoteConfig_callsFeatureFlagsServiceStart() async throws {
        let mockService = MockFeatureFlagsService()
        let viewModel = SplashViewModel(featureFlagsService: mockService)
        
        try await viewModel.loadFeatureFlags()
        
        XCTAssertTrue(mockService.startCalled)
    }
}
