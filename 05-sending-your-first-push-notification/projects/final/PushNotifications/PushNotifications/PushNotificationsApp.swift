import SwiftUI

@main
struct PushNotificationsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.swift)
  private var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
