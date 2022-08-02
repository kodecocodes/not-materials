import SwiftUI

@main
struct PushNotificationsApp: App {
  @UIApplicationDelegateAdaptor
  private var appDelegate: AppDelegate

  let controller = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, controller.container.viewContext)
        .environmentObject(appDelegate.notificationCenter)
    }
  }
}
