import UIKit
import UserNotifications

enum PushNotifications {
  public static let categoryIdentifier = "AcceptOrReject"

  public enum ActionIdentifier: String {
    case accept, reject
  }

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
    using notificationCenterDelegate: UNUserNotificationCenterDelegate? = nil
  ) {
    Task {
      let center = UNUserNotificationCenter.current()

      try await center.requestAuthorization(options: [.badge, .sound, .alert])

      center.delegate = notificationCenterDelegate

      await MainActor.run {
        application.registerForRemoteNotifications()
      }
    }
  }

  static func registerCustomActions() {
    let accept = UNNotificationAction(
      identifier: ActionIdentifier.accept.rawValue,
      title: "Accept")

    let reject = UNNotificationAction(
      identifier: ActionIdentifier.reject.rawValue,
      title: "Reject")

    let category = UNNotificationCategory(
      identifier: Self.categoryIdentifier,
      actions: [accept, reject],
      intentIdentifiers: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
  }
}
