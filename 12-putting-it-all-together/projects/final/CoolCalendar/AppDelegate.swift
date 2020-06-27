/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder {
  var window: UIWindow?

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoolCalendar")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })

    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()

  func createInvite(with title: String, starting: Date, ending: Date, accepted: Bool) {
    persistentContainer.performBackgroundTask { context in
      let invite = Invite(context: context)
      invite.title = title
      invite.start = starting
      invite.end = ending
      invite.accepted = accepted

      try? context.save()
    }
  }
  
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
}

extension AppDelegate: UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let vc = window?.rootViewController as! ViewController
    vc.managedObjectContext = persistentContainer.viewContext
    registerForPushNotifications(application: application)
    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      try? context.save()
    }
  }
  
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken
    deviceToken: Data) {
    
    registerCustomActions()
    sendPushNotificationDetails(
      to: "http://192.168.1.1:8080/api/token",
      using: deviceToken)
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    UserDefaults.appGroup.badge = 0
    application.applicationIconBadgeNumber = 0
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void) {
    
    completionHandler([.badge, .sound, .alert])
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping ()
    -> Void) {
    
    defer { completionHandler() }
    
    let formatter = ISO8601DateFormatter()
    let content = response.notification.request.content
    
    guard
      let choice =
      ActionIdentifier(rawValue: response.actionIdentifier),
      let userInfo = content.userInfo as? [String : Any],
      let title = userInfo["title"] as? String, !title.isEmpty,
      let start = userInfo["start"] as? String,
      let startDate = formatter.date(from: start),
      let end = userInfo["end"] as? String,
      let endDate = formatter.date(from: end),
      let calendarIdentifier = userInfo["id"] as? Int
    else {
      return
    }
    
    switch choice {
    case .accept:
      Server.shared.acceptInvitation(with: calendarIdentifier)
      createInvite(
        with: title,
        starting: startDate,
        ending: endDate,
        accepted: true)
      
    case .decline:
      Server.shared.declineInvitation(with: calendarIdentifier)
      createInvite(
        with: title,
        starting: startDate,
        ending: endDate,
        accepted: false)
      
    default:
      break
    }
  }
}
