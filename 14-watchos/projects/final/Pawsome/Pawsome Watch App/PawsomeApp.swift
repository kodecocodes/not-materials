import SwiftUI

@main
struct Pawsome_Watch_AppApp: App {
  private let local = LocalNotifications()

  @WKExtensionDelegateAdaptor(ExtensionDelegate.self)
  private var extensionDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }

    WKNotificationScene(
      controller: NotificationController.self,
      category: LocalNotifications.categoryIdentifier
    )

    WKNotificationScene(
      controller: RemoteNotificationController.self,
      category: RemoteNotificationController.categoryIdentifier
    )
  }
}
