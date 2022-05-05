//
//  ValidationService.swift
//  Football_API
//
//  Created by Emre Dogan on 05/05/2022.
//

import Foundation

struct VerificationService {
    func verifyUsername(_ username: String?) throws -> String {
        guard let username = username else {
            print("THROWING ERROR")
            throw VerifyError.invalidValue
        }
        
        guard username.count > 0 else {
            throw VerifyError.emptyValue
        }
        
        
        guard username.count > 5 else {
            throw VerifyError.nameTooShort
        }
        
        guard username.count < 25 else {
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
        
        guard password.count > 5 else {
            throw VerifyError.passwordTooShort
        }
        
        guard password.count < 15 else {
            throw VerifyError.passwordTooLong
        }
        
        return password
    }
}

enum VerifyError: LocalizedError {
    case emptyValue
    case invalidValue
    case nameTooShort
    case nameTooLong
    case passwordTooShort
    case passwordTooLong
    
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
            
        }
    }
}
