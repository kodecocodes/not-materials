import UserNotifications

final class NotificationCenter: NSObject {
  @Published var isBeachViewActive = false
}

extension NotificationCenter: ObservableObject {}

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
    if response.notification.request.content.userInfo["beach"] != nil {
      // In a real app you'd likely pull a URL from the beach data
      // and use that image.
      await MainActor.run {
        isBeachViewActive = true
      }
    }
  }
}
