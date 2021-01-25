// swiftlint:disable weak_delegate

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationDelegate = NotificationDelegate()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    registerForPushNotifications(application: application)
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    sendPushNotificationDetails(to: "http://192.168.1.39:8080/token", using: deviceToken)
  }
}
