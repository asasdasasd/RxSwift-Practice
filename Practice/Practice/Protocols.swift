//
//  Protocols.swift
//  Practice
//
//  Created by shen on 2017/3/7.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

enum ValidationResult {
    case ok(message: String)
    case empty
    case validatiog
    case failed(message: String)
}

enum SignupState {
    case signedUp(signedUp: Bool)
}

protocol GitHubAPI {
    func usernameAvailable(_ username: String) -> Observable<Bool>
    func signup(_ username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<ValidationResult>
    func validatePassword(_ password: String) -> ValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult
}

extension ValidationResult{
    var isValid: Bool{
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
    
}





