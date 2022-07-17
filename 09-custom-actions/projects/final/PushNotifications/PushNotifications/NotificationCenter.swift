import UserNotifications

final class NotificationCenter: NSObject {
}

extension NotificationCenter: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.banner, .sound, .badge]
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    let identity = response.notification.request.content.categoryIdentifier
    guard identity == PushNotifications.categoryIdentifier,
      let action = PushNotifications.ActionIdentifier(rawValue: response.actionIdentifier) else {
      return
    }

    switch action {
    case .accept: Counter.shared.accepted += 1
    case .reject: Counter.shared.rejected += 1
    }
  }
}
