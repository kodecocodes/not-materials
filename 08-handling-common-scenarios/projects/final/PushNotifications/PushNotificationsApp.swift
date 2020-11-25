import SwiftUI

@main
struct PushNotificationsApp: App {
  @StateObject var viewRouter = ViewRouter()

  let persistenceController = PersistenceController.shared
  
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
