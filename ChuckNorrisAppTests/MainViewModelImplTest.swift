//
//  MainViewModelImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
import Mockingbird
@testable import ChuckNorrisApp

final class MainViewModelImplTest: XCTestCase {
    
    private var mainViewModelImpl: MainViewModelImpl? = nil
    
//    private class MockedChuckNorrisWebClient: ChuckNorrisWebClient {
//        func getJoke() async throws -> JokeResponse? {
//            return JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
//        }
//    }
    
    private lazy var chuckNorrisWebClient = mock(ChuckNorrisWebClient.self)

    override func setUpWithError() throws {
        mainViewModelImpl = MainViewModelImpl(webClient: chuckNorrisWebClient)
    }

    func testGetJoke_mustReturnJoke() async throws {
        given(try await chuckNorrisWebClient.getJoke()).willReturn(JokeResponse(id: "1", iconUrl: "url", value: "Some joke"))
        
        let joke = try? await mainViewModelImpl?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
    }
    
    override func tearDown() {
        clearStubs(on: chuckNorrisWebClient)
    }
}
