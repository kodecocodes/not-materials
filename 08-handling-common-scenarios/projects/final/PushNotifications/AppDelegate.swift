import UIKit
import CoreData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  let notificationDelegate = NotificationDelegate()
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    registerForPushNotifications(application: application)
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    sendPushNotificationDetails(to: "http://192.168.1.1:8080", using: deviceToken)
  }

  func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    guard let text = userInfo["text"] as? String,
          let image = userInfo["image"] as? String,
          let url = URL(string: image) else {
      completionHandler(.noData)
      return
    }

    let context = PersistenceController.shared.container.viewContext
    context.perform {
      do {
        let message = Message(context: context)
        message.image = try Data(contentsOf: url)
        message.received = Date()
        message.text = text

        try context.save()

        completionHandler(.newData)
      } catch {
        completionHandler(.failed)
      }
    }
  }
}
