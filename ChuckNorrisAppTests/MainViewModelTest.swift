//
//  MainViewModelImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
@testable import ChuckNorrisApp

final class ChuckNorrisWebClientMock: ChuckNorrisWebClient, @unchecked Sendable {
    var getJokeReturnValue: JokeResponse?
    var getJokeCalled = false
    var getJokeShouldThrow = false
    
    func getJoke() async throws -> JokeResponse? {
        getJokeCalled = true
        if getJokeShouldThrow {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }
        return getJokeReturnValue
    }
}

@MainActor
final class MainViewModelTest: XCTestCase {
    
    private var mainViewModel: MainViewModel? = nil
    private var chuckNorrisWebClient = ChuckNorrisWebClientMock()

    override func setUpWithError() throws {
        chuckNorrisWebClient = ChuckNorrisWebClientMock()
        mainViewModel = MainViewModel(webClient: chuckNorrisWebClient)
    }

    func testGetJoke_mustReturnJoke() async throws {
        chuckNorrisWebClient.getJokeReturnValue = JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        
        let joke = try? await mainViewModel?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
        XCTAssertTrue(chuckNorrisWebClient.getJokeCalled)
    }
    
    override func tearDown() {
        // No-op
    }
}
