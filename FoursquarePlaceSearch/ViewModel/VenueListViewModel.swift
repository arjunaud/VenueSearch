//
//  VenueListViewModel.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 07/09/22.
//

import Foundation
import CoreLocation

/**
 Delegates methods to be impletemented by VenueListViewModel delegate.
 */
protocol VenueListViewModelDelegateProtocol: AnyObject {
    func showLoadingIndicator()
    func stopLoadingIndicator()
    func reloadData()
    func showErrorMessage(title:String, message: String)
    func showRadiusSelectionUI(title: String, message: String)
    func showNoVenuesLabel(text: String)
    func hideNoVeunuesLabel()
    func openLocationInMaps(location: CLLocationCoordinate2D, locationName: String)
}
/**
 View model for venue list which formats the venue.
 */
class VenueListViewModel {
    
    private let locationService: LocationServiceProtocol
    private let venueDataService: VenueDataServiceProtocol
    private weak var delegate: VenueListViewModelDelegateProtocol?
    private var currentLocation: CLLocation?
    private var nextPageURL: URL?
    private static let maxRadius:UInt = 100000
    private static let minRadius:UInt = 1
    private static let noVenuesFoundMessage = "No venues found. Please check your location settings, network, radius and tap on refresh."

    private var radius: UInt = maxRadius
    private var isLoadingVenueServiceData = false {
        didSet {
            if self.isLoadingVenueServiceData {
                self.delegate?.hideNoVeunuesLabel()
                self.delegate?.showLoadingIndicator()
            } else {
                self.delegate?.stopLoadingIndicator()
            }
        }
    }
    private var venueCellViewModels: [VenueCellViewModel] = [] {
        didSet {
            self.delegate?.reloadData()
        }
    }
    
    init(venueDataService: VenueDataServiceProtocol = VenueDataService(),
                  locationProvider: LocationServiceProtocol = LocationService(),
                  delegate: VenueListViewModelDelegateProtocol) {
        self.locationService = locationProvider
        self.venueDataService = venueDataService
        self.delegate = delegate
    }
    
    var venueCount: Int {
        return self.venueCellViewModels.count
    }
    
    func venueCellModelForRow(row: Int) -> VenueCellViewModel {
        return self.venueCellViewModels[row]
    }
    
    func refresh() {
        if !self.venueCellViewModels.isEmpty {
            self.venueCellViewModels.removeAll()
        }
        self.delegate?.showLoadingIndicator()
        self.locationService.fetchCurrentLocation { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.stopLoadingIndicator()
                switch result {
                    case .success(let location):
                        self.currentLocation = location
                        self.fetchVenues(location: location)
                        break
                    case .failure(let error):
                    self.handleLocationServiceError(error: error)
                        break
                }
            }
        }
    }
    
    func viewDidLoad() {
        self.refresh()
    }
    
    func fetchMoreVenuesIfNeeded() {
        guard let nextPageURL = nextPageURL, self.isLoadingVenueServiceData == false else {
            return
        }
        self.isLoadingVenueServiceData = true
        self.venueDataService.fetchVenues(url: nextPageURL) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingVenueServiceData = false
                switch result {
                case .success((let venues, let nextPageURL)):
                    self.updateVenues(venues: venues, nextPageURL: nextPageURL, append: true)
                    break
                    
                case.failure(_):
                    break
                }
            }
        }
    }
    
    func setRadius(radiusString: String?) {
        guard let radiusString = radiusString, let radius = UInt(radiusString), radius >= Self.minRadius, radius <= Self.maxRadius else {
            self.delegate?.showRadiusSelectionUI(title: "Invalid radius", message: "Please enter a radius between 1 and 100000 meters.")
            return
        }
        self.radius = radius
        self.refresh()
    }
    
    func radiusSelectionTapped() {
        self.delegate?.showRadiusSelectionUI(title: "Enter a Radius", message: "Please enter a radius between 1 and 100000 meters.")
    }
    
    //MARK: - Private -
    private func handleLocationServiceError(error: LocationServiceError) {
        switch error {
            case .locationFetchFailed(_):
                self.delegate?.showErrorMessage(title: "Location fetch failed",message: "Please check location settings on your device and tap refresh button in VenueFinder")
                    break
            case .devicePermisssionDenied:
                self.delegate?.showErrorMessage(title: "Device Location Services disabled",message: "Please enable Settings->Privacy->Location Services and tap refresh button in VenueFinder")
                break
            case .appPermissionDenied(_):
                self.delegate?.showErrorMessage(title: "App location permission denied",message: "Please give the app location permission in Settings->Privacy->Location Services and tap refresh button in VenueFinder")
                break
        }
        self.delegate?.showNoVenuesLabel(text: Self.noVenuesFoundMessage)
    }
    
    private func updateVenues(venues: [Venue], nextPageURL: URL? , append: Bool = false) {
        self.nextPageURL = nextPageURL
        let venueViewModels = venues.map({ venue in
            return VenueCellViewModel(venue: venue) { [weak self] in
                guard let self = self else {return}
                guard let geoLocation = venue.geoLocation else {
                    self.delegate?.showErrorMessage(title: "Venue Map Error", message: "Unable to open the current location since geolocation data is not available")
                    return
                }
                self.delegate?.openLocationInMaps(location: geoLocation, locationName: venue.name ?? "Venue")
                
            }
        })
        if append {
            self.venueCellViewModels.append(contentsOf: venueViewModels)
        } else {
            self.venueCellViewModels = venueViewModels
        }
    }
    
    private func fetchVenues(location:CLLocation) {
        self.isLoadingVenueServiceData = true
        self.venueDataService.fetchVenues(location: location.coordinate, radius: self.radius, limit: 50) { [weak self] (result) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.isLoadingVenueServiceData = false
                switch result {
                case .success((let venues , let nextPageURL)):
                    self.updateVenues(venues: venues, nextPageURL: nextPageURL)
                    if venues.isEmpty {
                        self.delegate?.showNoVenuesLabel(text: Self.noVenuesFoundMessage)
                        self.delegate?.showErrorMessage(title: "No Venues found", message: "No venues found for the given radius. Please refresh after increasing the radius.")
                    } else {
                        self.delegate?.hideNoVeunuesLabel()
                    }
                    break
                    
                case.failure(let venueDataServiceError):
                    self.handleVenueDataServiceError(error: venueDataServiceError)
                    break
                }
            }
        }
    }
    
    private func handleVenueDataServiceError(error: VenueDataServiceError) {
        switch error {
        case .ServerError(_), .DataFetchError, .DecodingError, .InvalidResponseError:
            self.delegate?.showErrorMessage(title: "Venue fetch error", message: "Venue fetch falied from server. Please tap on refresh after some time.")
            break
        case .NetworkError(_):
            self.delegate?.showErrorMessage(title: "Venue fetch error", message: "Unable to connect to server. Please troubleshoot your internet connection and tap on refresh.")
            break
        case .InvalidInput:
            self.delegate?.showErrorMessage(title: "Venue fetch error", message: "Something went wrong in the app. Please tap on refresh again.")
            break
        }
        self.delegate?.showNoVenuesLabel(text: Self.noVenuesFoundMessage)
    }
}
