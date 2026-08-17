//
//  MainViewModelImplTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 26/03/24.
//

import XCTest
import AVFoundation
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
    private var notificationManager = NotificationManagerMock()

    override func setUpWithError() throws {
        chuckNorrisWebClient = ChuckNorrisWebClientMock()
        notificationManager = NotificationManagerMock()
        let speechService = SpeechService(speechSynthesizer: AVSpeechSynthesizer())
        mainViewModel = MainViewModel(
            webClient: chuckNorrisWebClient,
            speechService: speechService,
            notificationManager: notificationManager
        )
    }

    func testGetJoke_mustReturnJoke() async throws {
        chuckNorrisWebClient.getJokeReturnValue = JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        
        let joke = try? await mainViewModel?.getJoke()
        
        XCTAssertEqual("1", joke?.id)
        XCTAssertEqual("url", joke?.iconUrl)
        XCTAssertEqual("Some joke", joke?.value)
        XCTAssertTrue(chuckNorrisWebClient.getJokeCalled)
    }
    
    func testConsumePendingJoke_whenHasPayload_returnsText() {
        notificationManager.pendingJokePayload = ("Chuck Norris counted to infinity.", false)
        
        let result = mainViewModel?.consumePendingJoke()
        
        XCTAssertEqual(result, "Chuck Norris counted to infinity.")
        XCTAssertTrue(notificationManager.consumePendingJokePayloadCalled)
        XCTAssertNil(notificationManager.pendingJokePayload)
    }
    
    func testConsumePendingJoke_whenHasPayloadWithSpeak_returnsText() {
        notificationManager.pendingJokePayload = ("Chuck Norris speaks.", true)
        
        let result = mainViewModel?.consumePendingJoke()
        
        XCTAssertEqual(result, "Chuck Norris speaks.")
        XCTAssertTrue(notificationManager.consumePendingJokePayloadCalled)
        XCTAssertNil(notificationManager.pendingJokePayload)
    }
    
    func testConsumePendingJoke_whenNoPayload_returnsNil() {
        notificationManager.pendingJokePayload = nil
        
        let result = mainViewModel?.consumePendingJoke()
        
        XCTAssertNil(result)
        XCTAssertTrue(notificationManager.consumePendingJokePayloadCalled)
    }
    
    override func tearDown() {
        // No-op
    }
}
