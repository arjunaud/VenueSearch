//
//  MockVenueListViewModelDelegate.swift
//  VenueFinderTests
//
//  Created by arjuna on 11/09/22.
//

import Foundation
import CoreLocation

@testable import VenueFinder

class MockVenueListViewModelDelegate: VenueListViewModelDelegateProtocol {
    typealias MockShowLoadingIndicatorBlock = () -> Void
    typealias MockStopLoadingIndicatorBlock = () -> Void
    typealias MockReloadDataBlock = () -> Void
    typealias MockShowErrorMessageBlock = (String, String) -> Void
    typealias MockShowRadiusSelectionUIBlock = (String, String) -> Void
    typealias MockShowNoVenuesLabelBlock = (String) -> Void
    typealias MockHideNoVenuesLabelBlock = () -> Void
    typealias MockOpenLocationInMapsBlock = (CLLocationCoordinate2D, String) -> Void
    
    var mockShowLoadingIndicatorBlock: MockShowLoadingIndicatorBlock?
    var mockStopLoadingIndicatorBlock: MockStopLoadingIndicatorBlock?
    var mockReloadDataBlock: MockReloadDataBlock?
    var mockShowErrorMessageBlock: MockShowErrorMessageBlock?
    var mockShowRadiusSelectionUIBlock: MockShowRadiusSelectionUIBlock?
    var mockShowNoVenuesLabelBlock: MockShowNoVenuesLabelBlock?
    var mockHideNoVenuesLabelBlock: MockHideNoVenuesLabelBlock?
    var mockOpenLocationInMapsBlock: MockOpenLocationInMapsBlock?

    func showLoadingIndicator() {
        self.mockShowLoadingIndicatorBlock?()
    }
    
    func stopLoadingIndicator() {
        self.mockStopLoadingIndicatorBlock?()
    }
    
    func reloadData() {
        self.mockReloadDataBlock?()
    }
    
    func showErrorMessage(title: String, message: String) {
        self.mockShowErrorMessageBlock?(title, message)
    }
    
    func showRadiusSelectionUI(title: String, message: String) {
        self.mockShowRadiusSelectionUIBlock?(title, message)
    }
    
    func showNoVenuesLabel(text: String) {
        self.mockShowNoVenuesLabelBlock?(text)
    }
    
    func hideNoVeunuesLabel() {
        self.mockHideNoVenuesLabelBlock?()
    }
    
    func openLocationInMaps(location: CLLocationCoordinate2D, locationName: String) {
        self.mockOpenLocationInMapsBlock?(location, locationName)
    }
}
