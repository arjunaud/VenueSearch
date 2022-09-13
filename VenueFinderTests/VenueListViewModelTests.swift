//
//  VenueListViewModelTests.swift
//  VenueListViewModelTests
//
//  Created by arjuna on 11/09/22.
//

import XCTest
@testable import VenueFinder
import CoreLocation

class VenueListViewModelTests: XCTestCase {

    var venueListViewModel: VenueListViewModel!
    var venueDataService: MockVenueDataService!
    var locationService: MockLocationService!
    var venueListViewModelDelegate: MockVenueListViewModelDelegate!
    var expectedCurrentLocation = CLLocationCoordinate2D(latitude: 1.1, longitude: 2.2)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
 
        self.venueDataService = MockVenueDataService()
        self.locationService = MockLocationService()
        self.venueListViewModelDelegate = MockVenueListViewModelDelegate()
        
        self.venueListViewModel = VenueListViewModel(venueDataService: venueDataService, locationProvider: locationService, delegate: venueListViewModelDelegate)
    }

//    override func tearDownWithError() throws {    }

    func testViewDidLoadUpdatesUISuccessfullyWhenDataServiceAndLocationProviderIsSuccess() throws {
        let locationServiceExpecatation = self.expectation(description: "locationServiceExpecatation")
        self.locationService.mockFetchCurrentLocationBlock = { [weak self] completion in
            guard let self = self else { return }
            locationServiceExpecatation.fulfill()
            completion(.success(CLLocation(latitude: self.expectedCurrentLocation.latitude, longitude: self.expectedCurrentLocation.longitude)))
        }
        
        let venueDataServiceExpectation = self.expectation(description: "venueDataServiceExpectation")
        self.venueDataService.mockFetchVenuesWithLocationBlock = { [weak self] (location, radius, limit, completion) in
            guard let self = self else { return }
            XCTAssertEqual(location.latitude, self.expectedCurrentLocation.latitude)
            XCTAssertEqual(location.longitude, self.expectedCurrentLocation.longitude)
            XCTAssertEqual(radius, 100000)
            XCTAssertEqual(limit, 50)
            guard let venues = try? self.venueDataService.loadVenuesFromJSONFile(fileName: "VenuesSuccessResponse") else {
                XCTFail("Dint get venue response")
                return
            }
            completion(.success((venues, nil)))
            venueDataServiceExpectation.fulfill()
        }
        
        let reloadDataWithProperDataExpectation = self.expectation(description: "reloadDataWithProperDataExpectation")
        self.venueListViewModelDelegate.mockReloadDataBlock = { [weak self] in
            guard let self = self else { return }
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(self.venueListViewModel.venueCount, 1)
            let venue1 = self.venueListViewModel.venueCellModelForRow(row: 0)
            XCTAssertEqual(venue1.name, "Venue1 (44m)")
            reloadDataWithProperDataExpectation.fulfill()
        }
        
        self.venueListViewModel.viewDidLoad()
        
        self.waitForExpectations(timeout: 30)
    }
    
    func testViewDidLoadDisplaysApprpriateErrorMessageWhenDeviceLocationIsOff() throws {
        let locationProviderExpecatation = self.expectation(description: "locationProviderExpecatation")
        self.locationService.mockFetchCurrentLocationBlock = { completion in
            locationProviderExpecatation.fulfill()
            completion(.failure(.devicePermisssionDenied))
        }
        
        let deviceLocationOffErrorShownExpectation = self.expectation(description: "deviceLocationOffErrorShownExpectation")
        self.venueListViewModelDelegate.mockShowErrorMessageBlock = { title , message in
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(title, "Device Location Services disabled")
            XCTAssertEqual(message, "Please enable Settings->Privacy->Location Services and tap refresh button in VenueFinder")
            deviceLocationOffErrorShownExpectation.fulfill()
        }
        
        self.venueListViewModel.viewDidLoad()
        
        self.waitForExpectations(timeout: 30)
    }
    
    func testViewDidLoadDisplaysApprpriateErrorMessageWhenAppLocationPermissionIsDeniedOff() throws {
        let locationServiceExpecatation = self.expectation(description: "locationServiceExpecatation")
        self.locationService.mockFetchCurrentLocationBlock = { completion in
            locationServiceExpecatation.fulfill()
            completion(.failure(.appPermissionDenied(.denied)))
        }
        
        let deviceLocationOffErrorShownExpectation = self.expectation(description: "deviceLocationOffErrorShownExpectation")
        self.venueListViewModelDelegate.mockShowErrorMessageBlock = { title , message in
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(title, "App location permission denied")
            XCTAssertEqual(message, "Please give the app location permission in Settings->Privacy->Location Services and tap refresh button in VenueFinder")
            deviceLocationOffErrorShownExpectation.fulfill()
        }
        
        self.venueListViewModel.viewDidLoad()
        
        self.waitForExpectations(timeout: 30)
    }
}
