// swiftlint:disable weak_delegate

import UIKit

public enum ActionIdentifier: String {
  case payment
}

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationDelegate = NotificationDelegate()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    registerForPushNotifications(application: application)
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    sendPushNotificationDetails(to: "http://192.168.1.39:8080/token", using: deviceToken)
    registerCustomActions()
  }

  private let categoryIdentifier = "ShowMap"

  private func registerCustomActions() {
    let identifier = ActionIdentifier.payment.rawValue
    let payment = UNNotificationAction(
      identifier: identifier,
      title: "Payment")

    let category = UNNotificationCategory(
      identifier: categoryIdentifier,
      actions: [payment],
      intentIdentifiers: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
  }
}
