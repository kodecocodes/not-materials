// swiftlint:disable weak_delegate

import SwiftUI

@main
struct PushNotificationsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
