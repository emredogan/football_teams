//
//  ErrorTypes.swift
//  Football_API
//
//  Created by Emre Dogan on 01/05/2022.
//

import Foundation

enum NetworkErrors: Error {
    case networkError(String)
    case JsonDecodeError(String)
    case FirebaseError(String)
}
