//
//  User.swift
//  Practice
//
//  Created by shen on 2017/2/17.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

struct User: Equatable, CustomDebugStringConvertible {
    
    var firstName: String
    var lastName: String
    var imageURL: String
    
    init(firstName: String, lastName: String, imageURL: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
    }
}

extension User {
    var debugDescription: String {
        return firstName + "  " + lastName
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.firstName == rhs.firstName &&
        lhs.lastName == lhs.lastName &&
        lhs.imageURL == rhs.imageURL
}
