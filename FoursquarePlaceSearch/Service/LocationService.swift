//
//  LocationService.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 07/09/22.
//

import Foundation
import CoreLocation

enum LocationServiceError: Error {
    case locationFetchFailed(Error?)
    case appPermissionDenied(CLAuthorizationStatus)
    case devicePermisssionDenied
}

/**
    Protocol to be used to get the current user geo location.
 */
protocol LocationServiceProtocol {
    func fetchCurrentLocation(completion: @escaping (Result<CLLocation, LocationServiceError>) -> Void)
    func authorizationStatus() -> CLAuthorizationStatus
}

/**
    This class implements LocationServiceProtocol to fetch the user location from CLLocationManager.
 */
class LocationService: NSObject, LocationServiceProtocol {
    
    private let locationManager: CLLocationManager
    private var completion: ((Result<CLLocation, LocationServiceError>) -> Void)?
    
    override init() {
        self.locationManager = CLLocationManager()
    }
    
    func fetchCurrentLocation(completion: @escaping (Result<CLLocation, LocationServiceError>) -> Void) {
        self.locationManager.delegate = self
        
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            let authStatus = self.locationManager.authorizationStatus
            if authStatus == .restricted || authStatus == .denied {
                completion(.failure(.appPermissionDenied(authStatus)))
            }
            else {
                self.completion = completion
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        }
        else {
            completion(.failure(.devicePermisssionDenied))
        }
    }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        return self.locationManager.authorizationStatus
    }
    
    
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let completion = self.completion
        self.completion = nil
        guard let lastLocation = locations.last else {
            print("Location Not fetched")
            completion?(.failure(.locationFetchFailed(nil)))
            return
        }
        completion?(.success(lastLocation))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard self.locationManager.authorizationStatus != .notDetermined else {
            return
        }
        self.completion?(.failure(.locationFetchFailed(error)))
        self.completion = nil
    }
    
}
