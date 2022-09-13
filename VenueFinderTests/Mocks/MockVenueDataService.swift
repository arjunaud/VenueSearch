//
//  MockVenueDataService.swift
//  VenueFinderTests
//
//  Created by arjuna on 11/09/22.
//

import Foundation
import CoreLocation

@testable import VenueFinder


class MockVenueDataService: VenueDataServiceProtocol {
    typealias MockFetchVenuesWithLocationBlock =  (CLLocationCoordinate2D, UInt, UInt, (Result<([Venue], URL?), VenueDataServiceError>) -> Void) -> Void
    typealias MockFetchVenuesWithURLBlock = (URL, (Result<([Venue], URL?), VenueDataServiceError>) -> Void) -> Void
    
    var mockFetchVenuesWithLocationBlock: MockFetchVenuesWithLocationBlock?
    var mockFetchVenuesWithURLBlock: MockFetchVenuesWithURLBlock?
    
    func fetchVenues(location: CLLocationCoordinate2D, radius: UInt, limit: UInt, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void) {
        self.mockFetchVenuesWithLocationBlock?(location, radius, limit, completion)
    }
    
    func fetchVenues(url: URL, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void) {
        self.mockFetchVenuesWithURLBlock?(url, completion)
    }
    
    func loadVenuesFromJSONFile(fileName: String) throws -> [Venue] {
        guard let path = Bundle(for: VenueListViewModelTests.self).path(forResource: fileName, ofType: "json")
                 else { return  []}
         let data = try Data(contentsOf: URL(fileURLWithPath: path))
         let response = try JSONDecoder().decode(VenueResponse.self, from: data)
        return response.results
    }
    
}
