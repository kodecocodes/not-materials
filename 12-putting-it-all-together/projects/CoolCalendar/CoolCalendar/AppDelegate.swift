import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationDelegate = NotificationDelegate()

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
      title: "Comment", options: [])

    let category = UNNotificationCategory(
      identifier: categoryIdentifier,
      actions: [accept, decline, comment],
      intentIdentifiers: [])

    UNUserNotificationCenter
      .current()
      .setNotificationCategories([category])
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    registerForPushNotifications(application: application)
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    sendPushNotificationDetails(to: "http://192.168.1.39:8080/token", using: deviceToken)
    registerCustomActions()
  }
}
