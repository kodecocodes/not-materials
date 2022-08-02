import SwiftUI
import UserNotifications
import UserNotificationsUI

import CoreLocation
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  enum ActionIdentifier: String {
    case accept
    case cancel
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }

  private lazy var paymentView: PaymentView = {
    let paymentView = PaymentView()
    paymentView.onPaymentRequested = { [weak self] payment in
      self?.resignFirstResponder()
    }
    return paymentView
  }()

  override var inputView: UIView? {
    return paymentView
  }

  var region: MKCoordinateRegion!
  var mapViewHost: UIHostingController<MapView>!

  @IBOutlet var label: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any required interface initialization here.
  }

  private func decodeUserInfo(_ notification: UNNotification) {
    let userInfo = notification.request.content.userInfo

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
      longitudinalMeters: radius
    )
  }

  func didReceive(_ notification: UNNotification) {
    decodeUserInfo(notification)
    let mapView = MapView(region: region, image: getImage(notification))
    mapViewHost = UIHostingController(rootView: mapView)
    addChild(mapViewHost)
    view.addSubview(mapViewHost.view)
    mapViewHost.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      mapViewHost.view.topAnchor.constraint(equalTo: view.topAnchor),
      mapViewHost.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapViewHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapViewHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    mapViewHost.didMove(toParent: self)
  }

  func didReceive(
    _ response: UNNotificationResponse
  ) async -> UNNotificationContentExtensionResponseOption {
    _ = becomeFirstResponder()
    return .doNotDismiss
  }

  func getImage(_ notification: UNNotification) -> Image? {
    guard
      let attachment = notification.request.content.attachments.first,
      attachment.url.startAccessingSecurityScopedResource()
    else {
      return nil
    }

    defer { attachment.url.stopAccessingSecurityScopedResource() }

    guard
      let data = try? Data(contentsOf: attachment.url),
      let uimage = UIImage(data: data)
    else {
      return nil
    }

    return Image(uiImage: uimage)
  }
}
