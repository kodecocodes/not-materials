import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  @IBOutlet private weak var mapView: MKMapView?
  @IBOutlet private weak var imageView: UIImageView?

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override var inputView: UIView? {
    return paymentView
  }

  private lazy var paymentView: PaymentView = {
    let paymentView = PaymentView()
    paymentView.onPaymentRequested = { [weak self] payment in
      self?.resignFirstResponder()
    }
    
    return paymentView
  }()

  func didReceive(_ notification: UNNotification) {
    guard let mapView = mapView else {
      return
    }

    let userInfo = notification.request.content.userInfo
    
    guard let latitude = userInfo["latitude"] as? CLLocationDistance,
          let longitude = userInfo["longitude"] as? CLLocationDistance,
          let radius = userInfo["radius"] as? CLLocationDistance else {
      return
    }
    
    let location = CLLocation(latitude: latitude,
                              longitude: longitude)
    let region = MKCoordinateRegion(center: location.coordinate,
                                    latitudinalMeters: radius,
                                    longitudinalMeters: radius)
    
    mapView.setRegion(region, animated: false)

    var images: [UIImage] = []

    notification.request.content.attachments.forEach { attachment in
      if attachment.url.startAccessingSecurityScopedResource() {
        if let data = try? Data(contentsOf: attachment.url),
           let image = UIImage(data: data) {
          images.append(image)
        }

        attachment.url.stopAccessingSecurityScopedResource()
      }
    }

    imageView?.image = images.first
  }

  func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
    becomeFirstResponder()
    completion(.doNotDismiss)
  }
}
