// swiftlint:disable weak_delegate

import UIKit
import CoreData

public let categoryIdentifier = "AcceptOrReject"

public enum ActionIdentifier: String {
  case accept, reject
}

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationDelegate = NotificationDelegate()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    registerForPushNotifications(application: application)
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    sendPushNotificationDetails(to: "http://192.168.1.1:8080", using: deviceToken)
    registerCustomActions()
  }

  private func registerCustomActions() {
    let accept = UNNotificationAction(
      identifier: ActionIdentifier.accept.rawValue,
      title: "Accept")

    let reject = UNNotificationAction(
      identifier: ActionIdentifier.reject.rawValue,
      title: "Reject")

    let category = UNNotificationCategory(
      identifier: categoryIdentifier,
      actions: [accept, reject],
      intentIdentifiers: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
  }
}
