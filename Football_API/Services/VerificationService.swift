//
//  ValidationService.swift
//  Football_API
//
//  Created by Emre Dogan on 05/05/2022.
//

import Foundation

struct VerificationService {
    let minUserNameLength = 5
    let maxUserNameLength = 25
    
    let minPassLength = 5
    let maxPassLength = 15
    
    func verifyUsername(_ username: String?) throws -> String {
        guard let username = username else {
            throw VerifyError.invalidValue
        }
        
        guard username.count > 0 else {
            throw VerifyError.emptyValue
        }
        
        guard username.count > minUserNameLength else {
            throw VerifyError.nameTooShort
        }
        
        guard username.count < maxUserNameLength else {
            throw VerifyError.nameTooLong
        }
        
        return username
    }
    
    func verifyPassword(_ password: String?) throws -> String {
        guard let password = password else {
            throw VerifyError.invalidValue
        }
        
        guard password.count > 0 else {
            throw VerifyError.emptyValue
        }
        
        guard password.count > minPassLength else {
            throw VerifyError.passwordTooShort
        }
        
        guard password.count < maxPassLength else {
            throw VerifyError.passwordTooLong
        }
        
        return password
    }
    
    func verifyCredentials(_ username: String?, _ password: String?) throws {
        if !isValidPass(username, password) {
            throw VerifyError.authFail
        }
    }
    
    func isValidPass(_ username: String?, _ password: String?) -> Bool {
        return username == WelcomeViewController.validUsername && password == WelcomeViewController.validPassword
    }
}

enum VerifyError: Error {
    case emptyValue
    case invalidValue
    case nameTooShort
    case nameTooLong
    case passwordTooShort
    case passwordTooLong
    case authFail
    
    var errorDesc: String? {
        switch self {
        case .emptyValue:
            return "User name or password field is empty"
        case .nameTooLong:
            return "User name is too long"
        case .nameTooShort:
            return "User name is too short"
        case .passwordTooShort:
            return "Password is too short"
        case .passwordTooLong:
            return "Password is too long"
        case .invalidValue:
            return "User name field is invalid"
        case .authFail:
            return "Wrong user name or password"
        }
    }
}
