import Foundation
import CoreLocation
import Contacts
import Combine

final class LocationManager: NSObject, ObservableObject {
  @Published private(set) var placemark: CLPlacemark?
  @Published private(set) var authorized = false
  @Published private(set) var authorizationErrorMessage = "Requesting permissions."

  var locationManager = CLLocationManager()

  override init() {
    super.init()
    locationManager.delegate = self
  }

  func requestAuthorization() {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      authorized = false
      locationManager.requestWhenInUseAuthorization()

    case .restricted:
      authorized = false
      authorizationErrorMessage =
        "This device is not allowed to use location services."

    case .denied:
      authorized = false
      authorizationErrorMessage = "Location services must be enabled."

    case .authorizedWhenInUse, .authorizedAlways:
      authorized = true

    default:
      break
    }

    locationManager.startUpdatingLocation()
  }
}

extension LocationManager: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorized = manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedAlways
  }
}
