//
//  ChuckNorrisService.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

class ChuckNorrisService {
    var baseUrl: String
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func getRandomJoke() async throws -> JokeResponse? {
        let request = AF.request("\(baseUrl)/random")
        return try await request.serializingDecodable(JokeResponse.self).value
    }
}