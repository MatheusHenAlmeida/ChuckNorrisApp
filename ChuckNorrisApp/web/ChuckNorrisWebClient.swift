//
//  ChuckNorrisWebClient.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

class ChuckNorrisWebClient {
    
    func getJoke() async throws -> JokeResponse? {
        let request = AF.request("https://api.chucknorris.io/jokes/random")
        return try await request.serializingDecodable(JokeResponse.self).value
    }
}
