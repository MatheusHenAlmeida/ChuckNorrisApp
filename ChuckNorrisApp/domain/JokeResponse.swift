//
//  JokeResponse.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import Foundation

struct JokeResponse: Decodable {
    let id: String?
    let iconUrl: String?
    let value: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case iconUrl = "icon_url"
        case value
    }
}
