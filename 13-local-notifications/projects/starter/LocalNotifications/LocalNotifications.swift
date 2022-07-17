import SwiftUI
import Combine

@MainActor
final class LocalNotifications: NSObject, ObservableObject {
  @Published var authorized = false

  private let center = UNUserNotificationCenter.current()
}
