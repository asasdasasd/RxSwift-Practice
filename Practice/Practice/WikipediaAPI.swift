//
//  WikipediaAPI.swift
//  Practice
//
//  Created by shen on 2017/3/8.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

func apiError(_ error: String) -> NSError {
    //622262 0620023204646
    return NSError(domain: "WikipediaAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
}

public let wikipediaParseError = apiError("Error during parsing")

protocol wikipediaAPI {
    func getSearchResults(_ query: String) -> Observable<[WikipediaSearchResult]>
    func articleContent(_ searchResult: WikipediaSearchResult) -> Observable<WikipediaPage>
}

class DefaultWikipediaAPI: wikipediaAPI {
    static let sharedAPI = DefaultWikipediaAPI()
    
    let $: Dependencies = Dependencies.sharedDependencies
    
    let loadingWikipediaData = ActivityIndicator()
    
    private init() { }
    
    func JSON(_ url: URL) -> Observable<Any> {
        return $.URLSession
            .rx.json(url: url)
            .trackActivity(loadingWikipediaData)
    }
    
    func getSearchResults(_ query: String) -> Observable<[WikipediaSearchResult]> {
        let escapedQuery = query.URLEscaped
        let urlContent = "http://en.wikipedia.org/w/api.php?action=opensearch&search=\(escapedQuery)"
        
        let url = URL(string: urlContent)!
        
        return JSON(url)
            .observeOn($.backgroundWorkScheduler)
            .map{ json in
                guard let json = json as? [AnyObject] else {
                    throw exampleError("Parsing error")
                }
                
                return try WikipediaSearchResult.parseJSON(json)
            }
            .observeOn($.mainScheduler)
        
    }
    
    func articleContent(_ searchResult: WikipediaSearchResult) -> Observable<WikipediaPage> {
        let escapedPage = searchResult.title.URLEscaped
        guard let url = URL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=\(escapedPage)&format=json") else {
            return Observable.error(apiError("Can't create url"))
        }
        
        return JSON(url)
            .map { jsonResult in
                guard let json = jsonResult as? NSDictionary else {
                    throw exampleError("Parsing error")
                }
                
                return try WikipediaPage.parseJSON(json)
            }
            .observeOn($.mainScheduler)
    }
}

class Dependencies {
    
    // *****************************************************************************************
    // !!! This is defined for simplicity sake, using singletons isn't advised               !!!
    // !!! This is just a simple way to move services to one location so you can see Rx code !!!
    // *****************************************************************************************
    static let sharedDependencies = Dependencies() // Singleton
    
    let URLSession = Foundation.URLSession.shared
    let backgroundWorkScheduler: ImmediateSchedulerType
    let mainScheduler: SerialDispatchQueueScheduler
    let wireframe: Wireframe
    let reachabilityService: ReachabilityService
    
    private init() {
        wireframe = DefaultWireframe()
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        #if !RX_NO_MODULE
            operationQueue.qualityOfService = QualityOfService.userInitiated
        #endif
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        mainScheduler = MainScheduler.instance
        reachabilityService = try! DefaultReachabilityService() // try! is only for simplicity sake
    }
    
}

