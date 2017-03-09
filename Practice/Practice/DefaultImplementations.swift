//
//  DefaultImplementations.swift
//  Practice
//
//  Created by shen on 2017/3/7.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import RxSwift
import RxCocoa

import struct Foundation.CharacterSet
import struct Foundation.URL
import struct Foundation.URLRequest
import struct Foundation.NSRange
import class Foundation.URLSession
import func Foundation.arc4random

class GitHubDefaultAPI: GitHubAPI {
    let URLSession: URLSession
    
    static let sharedAPI = GitHubDefaultAPI(URLSession: Foundation.URLSession.shared)
    
    init(URLSession: URLSession) {
        self.URLSession = URLSession
    }
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        
        let url = URL(string: "https://github.com/\(username.URLEscaped)")
        let request = URLRequest(url: url!)
        return self.URLSession.rx.response(request: request)
            .map({ (response, _)  in
                return response.statusCode == 404
            })
            .catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : true
        
        return Observable.just(signupResult)
            .delay(1.0, scheduler: MainScheduler.instance)
    }
}



class GitHubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI
    
    static let sharedValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)
    
    init(API: GitHubAPI) {
        self.API = API
    }
    
    let minPasswordCount = 5
    
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.characters.count == 0 {
            return .just(.empty)
        }
        
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = ValidationResult.validatiog
        
        return API
            .usernameAvailable(username)
            .map({ (available) in
                if available {
                    return .ok(message: "Username available")
                } else {
                    return .failed(message: "Username already taken")
                }
            })
            .startWith(loadingValue)
        
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0{
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        return .ok(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.characters.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "Password repeated")
        } else {
            return .failed(message: "Password different")
        }
    }
    
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validatiog:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty, .validatiog:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: UIBindingObserver<Base, ValidationResult>{
        return UIBindingObserver(UIElement: base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
