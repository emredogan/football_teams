//
//  Result.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import Foundation

struct Result: Decodable {
    let get: String
    let results: Int
    let response: [Response]
}

struct Response : Decodable {
    let league : League
}

struct League: Decodable {
    let name: String
    let standings : [[Standings]]
}

struct Standings : Decodable {
    let team: Team
}

struct Team : Decodable {
    let name: String
    let logo: String
}


