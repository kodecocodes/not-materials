import UIKit
import UserNotifications

extension AppDelegate {
  func registerForPushNotifications(application: UIApplication) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.badge, .sound, .alert]) {
      [weak self] granted, _ in

      guard granted else { return }

      center.delegate = self?.notificationDelegate

      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
    }
  }

  func sendPushNotificationDetails(to urlString: String, using deviceToken: Data) {
    guard let url = URL(string: urlString) else {
      fatalError("Invalid URL string")
    }

    var details = TokenDetails(token: deviceToken)

    #if DEBUG
    details.debug.toggle()
    print(details)
    #endif

    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = details.encoded()

    URLSession.shared.dataTask(with: request).resume()
  }
}


