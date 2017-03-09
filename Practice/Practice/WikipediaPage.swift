//
//  WikipediaPage.swift
//  Practice
//
//  Created by shen on 2017/3/8.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import Foundation

struct WikipediaPage {
    let title: String
    let text: String
    
    static func parseJSON(_ json: NSDictionary) throws -> WikipediaPage {
        guard
            let parse = json.value(forKey: "parse"),
            let title = (parse as AnyObject).value(forKey: "title") as? String,
            let t = (parse as AnyObject).value(forKey: "text"),
            let text = (t as AnyObject).value(forKey: "*") as? String else {
                throw apiError("Error parsing page content")
        }
        
        return WikipediaPage(title: title, text: text)
    }
}
