//
//  ChuckNorrisWebClientImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
import Mockingbird
@testable import ChuckNorrisApp

final class ChuckNorrisWebClientImplTest: XCTestCase {
    
    private var webClient: ChuckNorrisWebClientImpl? = nil
    
    private lazy var chuckNorrisService = mock(ChuckNorrisService.self)

    override func setUpWithError() throws {
        webClient = ChuckNorrisWebClientImpl(webService: chuckNorrisService)
    }

    func testGetJoke_mustReturnJoke() async throws {
        given(await chuckNorrisService.getRandomJoke()).willReturn(JokeResponse(id: "1", iconUrl: "url", value: "Some joke"))
        
        let joke = try? await webClient?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
        verify(await chuckNorrisService.getRandomJoke()).wasCalled()
    }

    override func tearDown() {
        clearStubs(on: chuckNorrisService)
    }
}
