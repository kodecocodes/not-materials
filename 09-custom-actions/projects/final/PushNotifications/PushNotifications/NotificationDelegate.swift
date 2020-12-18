import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound, .badge])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    defer { completionHandler() }

    let identity = response.notification.request.content.categoryIdentifier
    guard identity == categoryIdentifier,
      let action = ActionIdentifier(rawValue: response.actionIdentifier) else {
      return
    }

    switch action {
    case .accept: Counter.shared.accepted += 1
    case .reject: Counter.shared.rejected += 1
    }
  }
}
