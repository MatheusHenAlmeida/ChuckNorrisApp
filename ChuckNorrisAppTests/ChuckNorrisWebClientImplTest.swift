//
//  ChuckNorrisWebClientImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
@testable import ChuckNorrisApp

final class ChuckNorrisWebClientImplTest: XCTestCase {
    
    private var webClient: ChuckNorrisWebClientImpl? = nil
    
    private class MockedChuckNorrisService: ChuckNorrisService {
        override func getRandomJoke() async throws -> JokeResponse? {
            return JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        }
    }

    override func setUpWithError() throws {
        webClient = ChuckNorrisWebClientImpl(webService: MockedChuckNorrisService(baseUrl: "url"))
    }

    func testGetJoke_mustReturnJoke() async throws {
        let joke = try? await webClient?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
    }

}
