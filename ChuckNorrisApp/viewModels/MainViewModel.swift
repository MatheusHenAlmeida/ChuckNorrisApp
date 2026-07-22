//
//  MainViewModel.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation

@MainActor
protocol MainViewModelType {
    func getJoke() async throws -> JokeResponse?
    func speech(message: String)
}

@MainActor
class MainViewModel: MainViewModelType {
    var webClient: ChuckNorrisWebClient
    let speechService: SpeechService
    
    init(
        webClient: ChuckNorrisWebClient,
        speechService: SpeechService
    ) {
        self.webClient = webClient
        self.speechService = speechService
    }
    
    func getJoke() async throws -> JokeResponse? {
        return try await webClient.getJoke()
    }
    
    func speech(message: String) {
        speechService.speech(message: message)
    }
}
