// swiftlint:disable weak_delegate

import SwiftUI

@main
struct CoolCalendarApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate
  @Environment(\.scenePhase)
  private var scenePhase

  let persistenceController = PersistenceController.shared

  private func clearBadgeCount(phase: ScenePhase) {
    guard phase == .active else { return }

    UserDefaults.appGroup.badge = 0
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .onChange(of: scenePhase, perform: clearBadgeCount)
    }
  }
}
