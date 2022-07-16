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
}

extension NotificationCenter: ObservableObject {}
