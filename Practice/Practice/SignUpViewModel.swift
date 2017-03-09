//
//  SignUpViewModel.swift
//  Practice
//
//  Created by shen on 2017/3/7.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift


class SignupViewModel {
    let validatedUsername: Observable<ValidationResult>
    let validatedPassword: Observable<ValidationResult>
    let validatedPasswordRepeated: Observable<ValidationResult>
    
    let signupEnabled: Observable<Bool>
    
    let signedIn: Observable<Bool>
    
    let signingIn: Observable<Bool>
    
    init(input:(
            username: Observable<String>,
            password: Observable<String>,
            repeatedPassword: Observable<String>,
            loginTaps: Observable<Void>
        ),
         dependency:(
        API: GitHubAPI,
        validationService: GitHubValidationService,
        wireframe: Wireframe
        )
         ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        validatedUsername = input.username
            .flatMapLatest({ (username)  in
                return validationService.validateUsername(username)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(.failed(message:"Error cantacting server"))
            })
            .shareReplay(1)
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }
            .shareReplay(1)
        
        validatedPasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
            .shareReplay(1)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        let usernameAndPassword = Observable.combineLatest(input.username, input.password){ ($0, $1) }
        
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest({ (username, password)  in
                return API.signup(username, password: password)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(false)
                    .trackActivity(signingIn)
            })
            .flatMapLatest({ (loggedIn) -> Observable<Bool>  in
                let message = loggedIn ? "Signed in to GitHub" : "Sign in to GitHub failed"
                return wireframe.promptFor(message, cancelAction: "OK", actions: [])
                    .map({ (_)  in
                        
                        loggedIn
                    })
            })
            .shareReplay(1)
        
        signupEnabled = Observable.combineLatest(
            validatedUsername,
            validatedPassword,
            validatedPasswordRepeated,
            signingIn.asObservable()
        ) { username, password, repeatedPassword, signingIn in
            username.isValid &&
            password.isValid &&
            repeatedPassword.isValid &&
            !signingIn
        }
        .distinctUntilChanged()
        .shareReplay(1)
    }
    
}

