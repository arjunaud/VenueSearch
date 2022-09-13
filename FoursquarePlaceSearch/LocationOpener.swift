//
//  LocationOpener.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 11/09/22.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationOpenerProtocol {
    func openLocationInMap(location: CLLocationCoordinate2D)
}

class LocationOpener: LocationOpenerProtocol {
    func openLocationInMap(location: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps()
    }
}
