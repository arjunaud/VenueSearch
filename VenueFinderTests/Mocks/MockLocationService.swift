//
//  MockLocationService.swift
//  VenueFinderTests
//
//  Created by arjuna on 11/09/22.
//

import Foundation
import CoreLocation

@testable import VenueFinder

class MockLocationService: LocationServiceProtocol {
    
    typealias MockFetchCurrentLocationBlock = ((Result<CLLocation, LocationServiceError>) -> Void) -> Void
    typealias MockAuthorizationStatusBlock = () -> CLAuthorizationStatus
    
    var mockFetchCurrentLocationBlock: MockFetchCurrentLocationBlock?
    var mockAuthorizationStatusBlock: MockAuthorizationStatusBlock?
    
    func fetchCurrentLocation(completion: @escaping (Result<CLLocation, LocationServiceError>) -> Void) {
        self.mockFetchCurrentLocationBlock?(completion)
    }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        guard let status = self.mockAuthorizationStatusBlock?() else {
            return .notDetermined
        }
        return status
    }
    
}
