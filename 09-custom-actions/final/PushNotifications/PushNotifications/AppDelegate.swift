import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationCenter = NotificationCenter()

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
    notificationCenter.registerCustomActions()
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    guard
      let text = userInfo["text"] as? String,
      let image = userInfo["image"] as? String,
      let url = URL(string: image)
    else {
      return .noData
    }

    let context = PersistenceController.shared.container.viewContext

    do {
      return try await context.perform(schedule: .immediate) { () -> UIBackgroundFetchResult in
        let message = Message(context: context)
        message.image = try Data(contentsOf: url)
        message.received = Date()
        message.text = text

        try context.save()

        return .newData
      }
    } catch {
      return .failed
    }
  }
}
