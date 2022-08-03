import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationCenter = NotificationCenter()

  private let categoryIdentifier = "CalendarInvite"

  private func registerCustomActions() {
    let accept = UNNotificationAction(
      identifier: ActionIdentifier.accept.rawValue,
      title: "Accept")

    let decline = UNNotificationAction(
      identifier: ActionIdentifier.decline.rawValue,
      title: "Decline")

    let comment = UNTextInputNotificationAction(
      identifier: ActionIdentifier.comment.rawValue,
      title: "Comment",
      options: [])

    let category = UNNotificationCategory(
      identifier: categoryIdentifier,
      actions: [accept, decline, comment],
      intentIdentifiers: [])

    UNUserNotificationCenter
      .current()
      .setNotificationCategories([category])
  }

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                   [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    PushNotifications.register(in: application, using: notificationCenter)

    return true
  }

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    PushNotifications.send(token: deviceToken, to: "http://192.168.1.1:8080")
    registerCustomActions()
  }
}
