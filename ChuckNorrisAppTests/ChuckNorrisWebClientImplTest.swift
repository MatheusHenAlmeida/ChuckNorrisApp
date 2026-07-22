//
//  ChuckNorrisWebClientImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
@testable import ChuckNorrisApp

final class ChuckNorrisServiceMock: ChuckNorrisService {
    var getRandomJokeReturnValue: JokeResponse?
    var getRandomJokeCalled = false
    var getRandomJokeShouldThrow = false
    
    func getRandomJoke() async throws -> JokeResponse? {
        getRandomJokeCalled = true
        if getRandomJokeShouldThrow {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }
        return getRandomJokeReturnValue
    }
}

final class ChuckNorrisWebClientImplTest: XCTestCase {
    
    private var webClient: ChuckNorrisWebClientImpl? = nil
    private var chuckNorrisService = ChuckNorrisServiceMock()

    override func setUpWithError() throws {
        chuckNorrisService = ChuckNorrisServiceMock()
        webClient = ChuckNorrisWebClientImpl(webService: chuckNorrisService)
    }

    func testGetJoke_mustReturnJoke() async throws {
        chuckNorrisService.getRandomJokeReturnValue = JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        
        let joke = try? await webClient?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
        XCTAssertTrue(chuckNorrisService.getRandomJokeCalled)
    }

    override func tearDown() {
        // No-op
    }
}
