import MapKit
import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  @IBOutlet private weak var mapView: MKMapView?
  @IBOutlet private weak var imageView: UIImageView?

  override var canBecomeFirstResponder: Bool {
    return true
  }

  private lazy var paymentView: PaymentView = {
    let paymentView = PaymentView()
    paymentView.onPaymentRequested = { [weak self] _ in
      self?.resignFirstResponder()
    }
    return paymentView
  }()

  override var inputView: UIView? {
    return paymentView
  }

  var mediaPlayPauseButtonType: UNNotificationContentExtensionMediaPlayPauseButtonType {
    return .overlay
  }

  var mediaPlayPauseButtonFrame: CGRect {
    return CGRect(x: 0, y: 0, width: 44, height: 44)
  }

  var mediaPlayPauseButtonTintColor: UIColor {
    return .purple
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any required interface initialization here.
  }

  func didReceive(_ notification: UNNotification) {
    guard let mapView = mapView else { return }

    let userInfo = notification.request.content.userInfo

    guard let latitude = userInfo["latitude"] as? CLLocationDistance,
      let longitude = userInfo["longitude"] as? CLLocationDistance,
      let radius = userInfo["radius"] as? CLLocationDistance else {
      return
    }

    let location = CLLocation(latitude: latitude, longitude: longitude)
    let region = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: radius,
      longitudinalMeters: radius)

    mapView.setRegion(region, animated: false)

    let images: [UIImage] = notification.request.content.attachments
      .compactMap { attachment in
        guard attachment.url.startAccessingSecurityScopedResource(),
          let data = try? Data(contentsOf: attachment.url),
          let image = UIImage(data: data) else {
          return nil
        }

        attachment.url.stopAccessingSecurityScopedResource()
        return image
      }

    imageView?.image = images.first
  }

  func didReceive(
    _ response: UNNotificationResponse,
    completionHandler completion:
    @escaping (UNNotificationContentExtensionResponseOption) -> Void
  ) {
    becomeFirstResponder()
    completion(.doNotDismiss)
  }
}
