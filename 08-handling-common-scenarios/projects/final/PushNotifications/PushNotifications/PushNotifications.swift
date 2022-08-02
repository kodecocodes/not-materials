import UIKit
import UserNotifications

enum PushNotifications {
  static func send(token: Data, to url: String) {
    guard let url = URL(string: url) else {
      fatalError("Invalid URL string")
    }

    Task {
      let details = TokenDetails(token: token)

      var request = URLRequest(url: url)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "POST"
      request.httpBody = details.encoded()

      _ = try await URLSession.shared.data(for: request)
    }
  }

  static func register(
    in application: UIApplication,
    // 1
    using notificationDelegate: UNUserNotificationCenterDelegate? = nil
  ) {
    Task {
      let center = UNUserNotificationCenter.current()

      try await center.requestAuthorization(options: [.badge, .sound, .alert])

      // 2
      center.delegate = notificationDelegate

      await MainActor.run {
        application.registerForRemoteNotifications()
      }
    }
  }
}
