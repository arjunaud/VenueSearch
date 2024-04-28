//
//  VenueDataService.swift
//  FoursquarePlaceSearch
//
//  Created by arjuna on 06/09/22.
//

import Foundation
import CoreLocation

struct Category: Decodable {
    let name: String?
}

struct Venue: Decodable {
    let name: String?
    let location: Location?
    let categories: [Category]?
    let distance: UInt?
    let geoLocation: CLLocationCoordinate2D?
    
    enum CodingKeys: String, CodingKey {
        case name, location, categories, distance, geocodes, main
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.location = try? container.decode(Location.self, forKey: .location)
        self.categories = try? container.decode([Category].self, forKey: .categories)
        self.distance = try? container.decode(UInt.self, forKey: .distance)
        let geoCodesContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .geocodes)
        self.geoLocation = try? geoCodesContainer.decode(CLLocationCoordinate2D.self, forKey: .main)
    }
}

extension CLLocationCoordinate2D: Decodable {
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}

struct Location: Decodable {
    let address: String?
    enum CodingKeys: String, CodingKey {
        case address = "formatted_address"
    }
                            
}

enum VenueDataServiceError: Error {
    case ServerError(Int)
    case NetworkError(Error)
    case InvalidResponseError
    case DataFetchError
    case DecodingError
    case InvalidInput
}

/**
    Data service protocol to give the venue list for the given location and radius.
 */
protocol VenueDataServiceProtocol {
    func fetchVenues(location:CLLocationCoordinate2D, radius: UInt, limit: UInt, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void)
    func fetchVenues(url: URL, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void)

}


struct VenueResponse: Decodable {
    let results: [Venue]
}

/**
    Implements VenueDataServiceProtocol by fetching the venues from foursquare api.
 */
class VenueDataService: VenueDataServiceProtocol {
    func fetchVenues(url: URL, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void) {
        self.performRequest(request: URLRequest(url: url), completion: completion)
    }
    
    
    private static let host = "api.foursquare.com"
    private static let path = "/v3/places/search"
    
    func fetchVenues(location:CLLocationCoordinate2D, radius: UInt, limit: UInt, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void) {

        let ll = URLQueryItem(name: "ll", value: String(format:"%.4f,%.4f", location.latitude,location.longitude))
        
        let radius = URLQueryItem(name: "radius", value: "\(radius)")
        let limit = URLQueryItem(name: "limit", value: "\(limit)")
        let sort = URLQueryItem(name: "sort", value: "DISTANCE")
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = Self.path
        urlComponents.queryItems = [limit, ll, radius, sort]
        
        guard let url = urlComponents.url else {
            completion(.failure(.InvalidInput))
            return
        }
        
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 30.0)
        self.performRequest(request: request, completion: completion)
    }
    
    private func performRequest(request:URLRequest, completion: @escaping (Result<([Venue], URL?), VenueDataServiceError>) -> Void)
    {
        var urlRequest = request
        let headerFields = [
            "Accept": "application/json",
            "Authorization": "fsq3Uw4gVuTaJS7BbB5wCGZBExEnRZerCk8FbSDi3OvuJtc="
          ]
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headerFields
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                completion(.failure(.NetworkError(error!)))
                return
            }
            
            guard  let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.InvalidResponseError))
                return
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(.ServerError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.DataFetchError))
                return
            }
            
            guard let venueResponse = try? JSONDecoder().decode(VenueResponse.self, from: data) else {
                completion(.failure(.DecodingError))
                return
            }
            
            
            var nextPageURL: URL?
            
            if let link = httpResponse.value(forHTTPHeaderField: "Link"),
               var nextPageURLString = link.split(separator: ";").first
                {
                nextPageURLString.removeLast()
                nextPageURLString.removeFirst()
                nextPageURL = URL(string: String(nextPageURLString))
            }
            
            completion(.success((venueResponse.results, nextPageURL)))
        })

        dataTask.resume()
    }
}
