/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {
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

  enum ActionIdentifier: String {
    case accept
    case cancel
  }

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var imageView: UIImageView!

  override var canBecomeFirstResponder: Bool {
    return true
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any required interface initialization here.
  }
    
  func didReceive(_ notification: UNNotification) {
    let userInfo = notification.request.content.userInfo

    guard let latitude = userInfo["latitude"] as? CLLocationDistance,
          let longitude = userInfo["longitude"] as? CLLocationDistance,
          let radius = userInfo["radius"] as? CLLocationDistance else {
      return
    }

    let location = CLLocation(latitude: latitude, longitude: longitude)
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

    imageView.image = images.first
  }

  func didReceive(
    _ response: UNNotificationResponse,
    completionHandler completion:
    @escaping (UNNotificationContentExtensionResponseOption) -> Void) {

    becomeFirstResponder()
    completion(.doNotDismiss)
  }
}
