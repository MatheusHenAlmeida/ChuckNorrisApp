//
//  SpeechService.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import AVFoundation

class SpeechService {
    private var speechSynthesizer: AVSpeechSynthesizer?
    
    init(speechSynthesizer: AVSpeechSynthesizer) {
        self.speechSynthesizer = speechSynthesizer
    }
    
    public func speech(message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer?.speak(utterance)
    }
}
