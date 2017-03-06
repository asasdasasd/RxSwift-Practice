//
//  LocationViewController.swift
//  Practice
//
//  Created by shen on 2017/3/6.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation

private extension Reactive where Base: UILabel {
    var coordinates: UIBindingObserver<Base, CLLocationCoordinate2D>{
        return UIBindingObserver(UIElement: base, binding: { (label, location) in
            label.text = "Lat: \(location.latitude)\n Lon:\(location.longitude)"
        })
    }
    
}

class LocationViewController: ViewController {

    @IBOutlet weak var change: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        let geolocationService = GeolocationService.instance
        
        geolocationService.authorized
            .drive(tipLabel.rx.isHidden)
            .disposed(by: disposebag)
        
        geolocationService.location
            .drive(tipLabel.rx.coordinates)
            .disposed(by: disposebag)
        
        change.rx.tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
            .disposed(by: disposebag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        authorized = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
        }
        
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

class RxCLLocationManagerDelegateProxy : DelegateProxy
    , CLLocationManagerDelegate
, DelegateProxyType {
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let locationManager: CLLocationManager = object as! CLLocationManager
        return locationManager.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let locationManager: CLLocationManager = object as! CLLocationManager
        locationManager.delegate = delegate as? CLLocationManagerDelegate
    }
}

extension Reactive where Base: CLLocationManager {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy {
        return RxCLLocationManagerDelegateProxy.proxyForObject(base)
    }
    
    // MARK: Responding to Location Events
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { a in
                return try castOrThrow([CLLocation].self, a[1])
        }
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didFailWithError: Observable<NSError> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:)))
            .map { a in
                return try castOrThrow(NSError.self, a[1])
        }
    }
    
    #if os(iOS) || os(macOS)
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didFinishDeferredUpdatesWithError: Observable<NSError?> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFinishDeferredUpdatesWithError:)))
            .map { a in
                return try castOptionalOrThrow(NSError.self, a[1])
        }
    }
    #endif
    
    #if os(iOS)
    
    // MARK: Pausing Location Updates
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didPauseLocationUpdates: Observable<Void> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:)))
            .map { _ in
                return ()
        }
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didResumeLocationUpdates: Observable<Void> {
        return delegate.methodInvoked( #selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:)))
            .map { _ in
                return ()
        }
    }
    
    // MARK: Responding to Heading Events
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didUpdateHeading: Observable<CLHeading> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:)))
            .map { a in
                return try castOrThrow(CLHeading.self, a[1])
        }
    }
    
    // MARK: Responding to Region Events
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didEnterRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:)))
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
        }
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didExitRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
        }
    }
    
    #endif
    
    #if os(iOS) || os(macOS)
    
    /**
     Reactive wrapper for `delegate` message.
     */
    @available(OSX 10.10, *)
    public var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:)))
            .map { a in
                let stateNumber = try castOrThrow(NSNumber.self, a[1])
                let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
                let region = try castOrThrow(CLRegion.self, a[2])
                return (state: state, region: region)
        }
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: NSError)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:monitoringDidFailFor:withError:)))
            .map { a in
                let region = try castOptionalOrThrow(CLRegion.self, a[1])
                let error = try castOrThrow(NSError.self, a[2])
                return (region: region, error: error)
        }
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didStartMonitoringForRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:)))
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
        }
    }
    
    #endif
    
    #if os(iOS)
    
    // MARK: Responding to Ranging Events
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didRangeBeacons:in:)))
            .map { a in
                let beacons = try castOrThrow([CLBeacon].self, a[1])
                let region = try castOrThrow(CLBeaconRegion.self, a[2])
                return (beacons: beacons, region: region)
        }
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: NSError)> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:rangingBeaconsDidFailFor:withError:)))
            .map { a in
                let region = try castOrThrow(CLBeaconRegion.self, a[1])
                let error = try castOrThrow(NSError.self, a[2])
                return (region: region, error: error)
        }
    }
    
    // MARK: Responding to Visit Events
    
    /**
     Reactive wrapper for `delegate` message.
     */
    @available(iOS 8.0, *)
    public var didVisit: Observable<CLVisit> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:)))
            .map { a in
                return try castOrThrow(CLVisit.self, a[1])
        }
    }
    
    #endif
    
    // MARK: Responding to Authorization Changes
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map { a in
                let number = try castOrThrow(NSNumber.self, a[1])
                return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
        }
    }
    
    
    
}


fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

fileprivate func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

