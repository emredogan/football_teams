//
//  HTTPHeaderExtension.swift
//  Football_API
//
//  Created by Emre Dogan on 30/04/2022.
//

import Foundation
import Alamofire

// Convert dictionary to HTTPHeader for Alamofire
extension Dictionary where Key == String, Value == String {
    func toHeader() -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        for (key, value) in self  {
            headers.add(name: key, value: value)
        }
        return headers
    }
}
