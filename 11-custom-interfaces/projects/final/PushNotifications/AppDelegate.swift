import UIKit

public enum ActionIdentifier: String {
  case payment
}

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationDelegate = NotificationDelegate()

  private let categoryIdentifier = "ShowMap"

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

  private func registerCustomActions() {
    let ident = ActionIdentifier.payment.rawValue
    let payment = UNNotificationAction(identifier: ident,
                                       title: "Payment")

    let category = UNNotificationCategory(identifier: categoryIdentifier,
                                          actions: [payment],
                                          intentIdentifiers: [])

    UNUserNotificationCenter.current()
      .setNotificationCategories([category])
  }
}
