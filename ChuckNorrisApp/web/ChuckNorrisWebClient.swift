//
//  ChuckNorrisWebClient.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

protocol ChuckNorrisWebClient {
    func getJoke() async throws -> JokeResponse?
}

class ChuckNorrisWebClientImpl: ChuckNorrisWebClient {
    private var webService: ChuckNorrisService
    
    init(webService: ChuckNorrisService) {
        self.webService = webService
    }
    
    func getJoke() async throws -> JokeResponse? {
        return try await webService.getRandomJoke()
    }
}
