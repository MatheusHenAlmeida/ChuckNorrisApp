//
//  MainViewModelImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
@testable import ChuckNorrisApp

final class MainViewModelImplTest: XCTestCase {
    
    private var mainViewModelImpl: MainViewModelImpl? = nil
    
    private class MockedChuckNorrisWebClient: ChuckNorrisWebClient {
        func getJoke() async throws -> JokeResponse? {
            return JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mainViewModelImpl = MainViewModelImpl(webClient: MockedChuckNorrisWebClient())
    }

    func testGetJoke_mustReturnJoke() async throws {
        let joke = try? await mainViewModelImpl?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
    }
}
