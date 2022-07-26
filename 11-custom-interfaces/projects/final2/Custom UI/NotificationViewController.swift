import SwiftUI
import UserNotifications
import UserNotificationsUI
import CoreLocation
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  var region: MKCoordinateRegion!
  var locationName: String?

  override func loadView() {
    let rootView = MapView(region: region, locationName: locationName)
    let host = UIHostingController(rootView: rootView)
    host.view.translatesAutoresizingMaskIntoConstraints = false

    view = host.view

    NSLayoutConstraint.activate([
      host.view.topAnchor.constraint(equalTo: view.topAnchor),
      host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  func didReceive(_ notification: UNNotification) {
    let userInfo = notification.request.content.userInfo

    locationName = userInfo["title"] as? String

    guard
      let latitude = userInfo["latitude"] as? CLLocationDistance,
      let longitude = userInfo["longitude"] as? CLLocationDistance,
      let radius = userInfo["radius"] as? CLLocationDistance
    else {
      // Default to Apple Park if nothing provided
      region = .init(
        center: .init(latitude: 37.334886, longitude: -122.008988),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
      )

      return
    }

    let location = CLLocation(latitude: latitude, longitude: longitude)

    region = .init(
      center: location.coordinate,
      latitudinalMeters: radius,
      longitudinalMeters: radius)
  }
}
