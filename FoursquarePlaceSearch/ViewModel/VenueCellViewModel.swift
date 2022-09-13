//
//  VenueCellViewModel.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 12/09/22.
//

import Foundation

/**
 View model for venue list cell by formatting venue name, category, distance and address.
 */

struct VenueCellViewModel {
    typealias TapHandler = () -> Void
    private let venue: Venue
    static private var distanceFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.unitOptions = .providedUnit
        return formatter
    }
    init(venue: Venue, tapHandler: @escaping TapHandler) {
        self.venue = venue
        var distance = ""
        if let dist = venue.distance {
            var distUnit = Measurement(value: Double(dist), unit: UnitLength.meters)
            if dist > 100 {
                distUnit.convert(to: UnitLength.kilometers)
            }
            distance = " (" + Self.distanceFormatter.string(from: distUnit) + ")"
        }
        var venueName = ""
        if let name = venue.name {
            venueName = name + distance
        }
        self.name = venueName
        self.address = venue.location?.address ?? ""
        self.catogories = venue.categories?.compactMap({ category in
            category.name
        }).joined(separator: ", ") ?? ""
        self.tapHandler = tapHandler
    }
    
    let name: String
    let address: String
    let catogories: String
    let tapHandler: () -> Void
}
