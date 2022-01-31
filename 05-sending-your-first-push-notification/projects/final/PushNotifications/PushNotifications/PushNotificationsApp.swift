import SwiftUI

@main
struct PushNotificationsApp: App {
  @UIApplicationDelegateAdaptor
  private var appDelegate: AppDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
