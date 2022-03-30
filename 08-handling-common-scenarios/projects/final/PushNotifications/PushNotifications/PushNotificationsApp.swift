import SwiftUI

@main
struct PushNotificationsApp: App {
  @UIApplicationDelegateAdaptor
  private var appDelegate: AppDelegate

  let controller = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appDelegate.notificationCenter)
        .environment(\.managedObjectContext, controller.container.viewContext)
    }
  }
}
