//
//  ChuckNorrisService.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

protocol ChuckNorrisService {
    func getRandomJoke() async throws -> JokeResponse?
}

class ChuckNorrisServiceImpl: ChuckNorrisService {
    private var baseUrl: String
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func getRandomJoke() async throws -> JokeResponse? {
        let request = AF.request("\(baseUrl)/random", method: .get)
        return try await request.serializingDecodable(JokeResponse.self).value
    }
}
