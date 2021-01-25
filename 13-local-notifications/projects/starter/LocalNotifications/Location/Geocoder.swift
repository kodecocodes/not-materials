import SwiftUI
import Combine
import CoreLocation

final class Geocoder {
  private let geocoder = CLGeocoder()

  enum Error: Swift.Error {
    case other(Swift.Error)
    case noCoordinates
  }

  func lookup(address: String) -> AnyPublisher<CLLocationCoordinate2D, Error> {
    Deferred {
      Future { promise in
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
          if let error = error {
            promise(.failure(.other(error)))
            return
          }

          guard let placemark = placemarks?.first,
            let coordinates = placemark.location?.coordinate else {
            promise(.failure(.noCoordinates))
            return
          }

          promise(.success(coordinates))
        }
      }
    }.eraseToAnyPublisher()
  }
}
