//
//  Result.swift
//  Football_API
//
//  Created by Emre Dogan on 21/04/2022.
//

import Foundation

struct JsonResult: Codable {
    let get: String
    let results: Int
    let response: [Response]
}

struct Response : Codable {
    let league : League
}

struct League: Codable {
    let name: String
    let standings : [[Standings]]
}

struct Standings : Codable {
    let team: Team
}

struct Team : Codable {
    let name: String
    let logo: String
    var isSubscribed: Bool?
}


