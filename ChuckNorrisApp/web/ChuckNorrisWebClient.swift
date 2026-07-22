//
//  ChuckNorrisWebClient.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

protocol ChuckNorrisWebClient: Sendable {
    func getJoke() async throws -> JokeResponse?
}

class ChuckNorrisWebClientImpl: ChuckNorrisWebClient, @unchecked Sendable {
    private let webService: ChuckNorrisService
    
    init(webService: ChuckNorrisService) {
        self.webService = webService
    }
    
    func getJoke() async throws -> JokeResponse? {
        return try await webService.getRandomJoke()
    }
}
