import SwiftUI

@main
struct AppMain: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
