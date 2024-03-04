//
//  ChuckNorrisWebClient.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

class ChuckNorrisWebClient {
    private var webService: ChuckNorrisService
    
    init(webService: ChuckNorrisService) {
        self.webService = webService
    }
    
    func getJoke() async throws -> JokeResponse? {
        return try await webService.getRandomJoke()
    }
}
