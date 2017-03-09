//
//  SearchResultViewModel.swift
//  Practice
//
//  Created by shen on 2017/3/8.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchResultViewModel {
    let searchResult: WikipediaSearchResult
    
    var title: Driver<String>
    var imageURLs: Driver<[URL]>
    
    let API = DefaultWikipediaAPI.sharedAPI
    let $: Dependencies = Dependencies.sharedDependencies
    
    init(searchResult: WikipediaSearchResult) {
        self.searchResult = searchResult
        
        self.title = Driver.never()
        self.imageURLs = Driver.never()
        
        let URLs = configureImageURLs()
        
        self.imageURLs = URLs.asDriver(onErrorJustReturn:[])
        self.title = configureTitle(URLs).asDriver(onErrorJustReturn: "Error during fetching")
    }
    
    func configureTitle(_ imageURLs: Observable<[URL]>) -> Observable<String> {
        let searchResult = self.searchResult
        
        let loadingValue: [URL]? = nil
        
        return imageURLs
            .map(Optional.init)
            .startwith(loadingValue)
            .map{ URLs in
                if let URLs = URLs {
                    return "\(searchResult.title) (\(URLs.count) pictures)"
                } else {
                    return "\(searchResult.title) (loading...)"
                }
            }
            .retryOnBecomesReachable(" Service offline", reachabilityService: $.reachabilityService)
    }
    
    func configureImageURLs() -> Observable<[URL]> {
        let searchResult = self.searchResult
        
        return API.articleContent(searchResult)
            .ObservableOn($.backgroundWorkScheduler)
            .map{ page in
                do {
                    return try parseImageURLsfromHTMLSuitableForDisplay(page.text as NSString)
                } catch {
                    return []
                }
                
            }
            .shareReplayLatestWhileConnected()
    }
}

func parseImageURLsfromHTML(_ html: NSString) throws -> [URL]  {
    let regularExpression = try NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]+)\"[^>]*>", options: [])
    
    let matches = regularExpression.matches(in: html as String, options: [], range: NSMakeRange(0, html.length))
    
    return matches.map { match -> URL? in
        if match.numberOfRanges != 2 {
            return nil
        }
        
        let url = html.substring(with: match.rangeAt(1))
        
        var absoluteURLString = url
        if url.hasPrefix("//") {
            absoluteURLString = "http:" + url
        }
        
        return URL(string: absoluteURLString)
        }.filter { $0 != nil }.map { $0! }
}

func parseImageURLsfromHTMLSuitableForDisplay(_ html: NSString) throws -> [URL] {
    return try parseImageURLsfromHTML(html).filter {
        return $0.absoluteString.range(of: ".svg.") == nil
    }
}

extension ObservableConvertibleType {
    func retryOnBecomesReachable(_ valueOnFailure:E, reachabilityService: ReachabilityService) -> Observable<E> {
        return self.asObservable()
            .catchError { (e) -> Observable<E> in
                reachabilityService.reachability
                    .skip(1)
                    .filter { $0.reachable }
                    .flatMap { _ in
                        Observable.error(e)
                    }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
}

import class Dispatch.queue.DispatchQueue

public enum ReachabilityStatus {
    case reachable(viaWiFi: Bool)
    case unreachable
}

extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .reachable:
            return true
        case .unreachable:
            return false
        }
    }
}

protocol ReachabilityService {
    var reachability: Observable<ReachabilityStatus> { get }
}

enum ReachabilityServiceError: Error {
    case failedToCreate
}

class DefaultReachabilityService: ReachabilityService {
    
    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    
    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }
    
    let _reachability: Reachability
    
    init() throws {
        guard let reachabilityRef = Reachability() else { throw ReachabilityServiceError.failedToCreate }
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)
        
        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
        
        reachabilityRef.whenReachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.reachable(viaWiFi: reachabilityRef.isReachableViaWiFi)))
            }
        }
        
        reachabilityRef.whenUnreachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.unreachable))
            }
        }
        
        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }
    
    deinit {
        _reachability.stopNotifier()
    }
}
import SystemConfiguration
import struct Foundation.Notification
import class Foundation.NotificationCenter

public enum ReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr_in)
    case failedToCreateWithHostname(String)
    case unableToSetCallback
    case unableToSetDispatchQueue
}

public let ReachabilityChangedNotification = Notification.Name("ReachabilityChangedNotification")

func callback(reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    
    guard let info = info else { return }
    
    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
    
    DispatchQueue.main.async {
        reachability.reachabilityChanged()
    }
}

public class Reachability {
    
    public typealias NetworkReachable = (Reachability) -> ()
    public typealias NetworkUnreachable = (Reachability) -> ()
    
    public enum NetworkStatus: CustomStringConvertible {
        
        case notReachable, reachableViaWiFi, reachableViaWWAN
        
        public var description: String {
            switch self {
            case .reachableViaWWAN: return "Cellular"
            case .reachableViaWiFi: return "WiFi"
            case .notReachable: return "No Connection"
            }
        }
    }
    
    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?
    public var reachableOnWWAN: Bool
    
    // The notification center on which "reachability changed" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default
    
    public var currentReachabilityString: String {
        return "\(currentReachabilityStatus)"
    }
    
    public var currentReachabilityStatus: NetworkStatus {
        guard isReachable else { return .notReachable }
        
        if isReachableViaWiFi {
            return .reachableViaWiFi
        }
        if isRunningOnDevice {
            return .reachableViaWWAN
        }
        
        return .notReachable
    }
    
    fileprivate var previousFlags: SCNetworkReachabilityFlags?
    
    fileprivate var isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }()
    
    fileprivate var notifierRunning = false
    fileprivate var reachabilityRef: SCNetworkReachability?
    
    fileprivate let reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability")
    
    required public init(reachabilityRef: SCNetworkReachability) {
        reachableOnWWAN = true
        self.reachabilityRef = reachabilityRef
    }
    
    public convenience init?(hostname: String) {
        
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else { return nil }
        
        self.init(reachabilityRef: ref)
    }
    
    public convenience init?() {
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let ref: SCNetworkReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return nil }
        
        self.init(reachabilityRef: ref)
    }
    
    deinit {
        stopNotifier()
        
        reachabilityRef = nil
        whenReachable = nil
        whenUnreachable = nil
    }
}

public extension Reachability {
    
    // MARK: - *** Notifier methods ***
    func startNotifier() throws {
        
        guard let reachabilityRef = reachabilityRef, !notifierRunning else { return }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw ReachabilityError.unableToSetCallback
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.unableToSetDispatchQueue
        }
        
        // Perform an intial check
        reachabilitySerialQueue.async {
            self.reachabilityChanged()
        }
        
        notifierRunning = true
    }
    
    func stopNotifier() {
        defer { notifierRunning = false }
        guard let reachabilityRef = reachabilityRef else { return }
        
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }
    
    // MARK: - *** Connection test methods ***
    var isReachable: Bool {
        
        guard isReachableFlagSet else { return false }
        
        if isConnectionRequiredAndTransientFlagSet {
            return false
        }
        
        if isRunningOnDevice {
            if isOnWWANFlagSet && !reachableOnWWAN {
                // We don't want to connect when on 3G.
                return false
            }
        }
        
        return true
    }
    
    var isReachableViaWWAN: Bool {
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return isRunningOnDevice && isReachableFlagSet && isOnWWANFlagSet
    }
    
    var isReachableViaWiFi: Bool {
        
        // Check we're reachable
        guard isReachableFlagSet else { return false }
        
        // If reachable we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return true }
        
        // Check we're NOT on WWAN
        return !isOnWWANFlagSet
    }
    
    var description: String {
        
        let W = isRunningOnDevice ? (isOnWWANFlagSet ? "W" : "-") : "X"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"
        
        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

fileprivate extension Reachability {
    
    func reachabilityChanged() {
        
        let flags = reachabilityFlags
        
        guard previousFlags != flags else { return }
        
        let block = isReachable ? whenReachable : whenUnreachable
        block?(self)
        
        self.notificationCenter.post(name: ReachabilityChangedNotification, object:self)
        
        previousFlags = flags
    }
    
    var isOnWWANFlagSet: Bool {
        #if os(iOS)
            return reachabilityFlags.contains(.isWWAN)
        #else
            return false
        #endif
    }
    var isReachableFlagSet: Bool {
        return reachabilityFlags.contains(.reachable)
    }
    var isConnectionRequiredFlagSet: Bool {
        return reachabilityFlags.contains(.connectionRequired)
    }
    var isInterventionRequiredFlagSet: Bool {
        return reachabilityFlags.contains(.interventionRequired)
    }
    var isConnectionOnTrafficFlagSet: Bool {
        return reachabilityFlags.contains(.connectionOnTraffic)
    }
    var isConnectionOnDemandFlagSet: Bool {
        return reachabilityFlags.contains(.connectionOnDemand)
    }
    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !reachabilityFlags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    var isTransientConnectionFlagSet: Bool {
        return reachabilityFlags.contains(.transientConnection)
    }
    var isLocalAddressFlagSet: Bool {
        return reachabilityFlags.contains(.isLocalAddress)
    }
    var isDirectFlagSet: Bool {
        return reachabilityFlags.contains(.isDirect)
    }
    var isConnectionRequiredAndTransientFlagSet: Bool {
        return reachabilityFlags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }
    
    var reachabilityFlags: SCNetworkReachabilityFlags {
        
        guard let reachabilityRef = reachabilityRef else { return SCNetworkReachabilityFlags() }
        
        var flags = SCNetworkReachabilityFlags()
        let gotFlags = withUnsafeMutablePointer(to: &flags) {
            SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
        }
        
        if gotFlags {
            return flags
        } else {
            return SCNetworkReachabilityFlags()
        }
    }
}
