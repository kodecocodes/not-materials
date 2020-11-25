import SwiftUI
import Combine
import CoreLocation

final class Geocoder: NSObject, ObservableObject {
  private let geocoder = CLGeocoder()

  @Published private(set) var placemark: CLPlacemark?
  @Published private(set) var error: String?

  func lookup(address: String) {
    CLGeocoder().geocodeAddressString(address) { [weak self] placemarks, error in
      guard let self = self else { return }

      if let error = error {
        self.error = error.localizedDescription
        self.placemark = nil
        return
      }

      guard let placemark = placemarks?.first,
            let _ = placemark.location?.coordinate else {
        self.error = "Failed to get a coordinate"
        self.placemark = nil
        return
      }

      self.error = nil
      self.placemark = placemark
    }
  }
}
