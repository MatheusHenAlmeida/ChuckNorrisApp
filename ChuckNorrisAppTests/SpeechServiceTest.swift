//
//  SpeechServiceTest.swift
//  ChuckNorrisAppTests
//
//  Created by Antigravity on 09/07/26.
//

import XCTest
import AVFoundation
@testable import ChuckNorrisApp

final class SpeechServiceTest: XCTestCase {
    func testSpeech() {
        let speechSynthesizer = AVSpeechSynthesizer()
        let service = SpeechService(speechSynthesizer: speechSynthesizer)
        service.speech(message: "Chuck Norris can divide by zero.")
        XCTAssertTrue(true)
    }
}
