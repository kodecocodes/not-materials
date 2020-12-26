// swiftlint:disable weak_delegate

import SwiftUI

@main
struct CoolCalendarApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate

  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
