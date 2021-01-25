import Foundation
import CoreLocation

struct Location: Identifiable {
  let id = UUID()
  let coordinate: CLLocationCoordinate2D
}
