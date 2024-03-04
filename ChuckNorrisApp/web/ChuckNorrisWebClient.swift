//
//  ChuckNorrisWebClient.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation
import Alamofire

class ChuckNorrisWebClient {
    
    func getJoke() {
        let request = AF.request("https://api.chucknorris.io/jokes/random")
        request.responseDecodable(of: JokeResponse.self) { joke in
            print(joke)
        }
    }
}
