import UserNotifications
import SwiftUI

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
  @Published var isBeachViewActive = false

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    defer { completionHandler() }

    guard
      response.actionIdentifier == UNNotificationDefaultActionIdentifier
    else {
      return
    }

    if response.notification.request.content.userInfo["beach"] != nil {
      // In a real app you'd likely pull a URL from the beach data
      // and use that image.
      isBeachViewActive = true
    }
  }
}
