//
//  RandomUserAPI.swift
//  Practice
//
//  Created by shen on 2017/2/17.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import RxSwift
import struct Foundation.URL
import class Foundation.URLSession

class RandomUserAPI {
    
    static let sharedAPI = RandomUserAPI()
    
    private init(){}
    
    func getExampleUserResultSet() -> Observable<[User]> {
        let url = URL(string: "http://api.randomuser.me/?results=20")
        
        return URLSession.shared.rx.json(url: url!)
            .map({ (json) in
                guard let json = json as? [String: AnyObject] else {
                    throw exampleError("Castring to dictionary failed")
                }
                return try self.parseJSON(json)
            })
    }
    
    func parseJSON(_ json: [String: AnyObject]) throws -> [User] {
        guard let results = json["results"] as? [[String: AnyObject]] else {
            throw exampleError("Can't find results")
        }
        
        let userParsingError = exampleError("Can't parse user")
        
        let searchResult: [User] = try results.map({ (user)  in
            let name = user["name"] as? [String: String]
            let pictures = user["picture"] as? [String: String]
            
            guard let firstName = name?["first"], let lastName = name?["last"],
                let iamgeURL = pictures?["medium"] else{
                    throw userParsingError
            }
            
            let returnUser = User(
                firstName: firstName.capitalized,
                lastName: lastName.capitalized,
                imageURL: iamgeURL
          
            )
            return returnUser
        })
        return searchResult
    }
}

func exampleError(_ error: String, location: String = "\(#file):\(#line)") -> NSError {
    return NSError(domain: "ExampleError", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(location): \(error)"])
}
