//
//  MainViewModel.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation

protocol MainViewModel {
    func getJoke() async throws -> JokeResponse?
}

class MainViewModelImpl: MainViewModel {
    var webClient: ChuckNorrisWebClient
    
    init(webClient: ChuckNorrisWebClient) {
        self.webClient = webClient
    }
    
    func getJoke() async throws -> JokeResponse? {
        return try await webClient.getJoke()
    }
}
