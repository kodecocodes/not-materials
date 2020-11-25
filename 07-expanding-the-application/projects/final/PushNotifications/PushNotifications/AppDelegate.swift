import UIKit
import CoreData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    registerForPushNotifications(application: application)
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    sendPushNotificationDetails(to: "http://192.168.1.1:8080", using: deviceToken)
  }
}
