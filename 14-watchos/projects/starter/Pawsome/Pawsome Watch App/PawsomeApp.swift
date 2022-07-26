import SwiftUI

@main
struct Pawsome_Watch_AppApp: App {
  private let local = LocalNotifications()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }

    WKNotificationScene(
      controller: NotificationController.self,
      category: "myCategory"
    )
  }
}
