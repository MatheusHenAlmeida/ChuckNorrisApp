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
    func consumePendingJoke() -> String?
}

@MainActor
class MainViewModel: MainViewModelType {
    var webClient: ChuckNorrisWebClient
    let speechService: SpeechService
    let notificationManager: NotificationManager
    
    init(
        webClient: ChuckNorrisWebClient,
        speechService: SpeechService,
        notificationManager: NotificationManager = NotificationManagerImpl.shared
    ) {
        self.webClient = webClient
        self.speechService = speechService
        self.notificationManager = notificationManager
    }
    
    func getJoke() async throws -> JokeResponse? {
        return try await webClient.getJoke()
    }
    
    func speech(message: String) {
        speechService.speech(message: message)
    }
    
    func consumePendingJoke() -> String? {
        guard let payload = notificationManager.consumePendingJokePayload() else { return nil }
        if payload.speak {
            speech(message: payload.text)
        }
        return payload.text
    }
}
