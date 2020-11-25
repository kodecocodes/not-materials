import SwiftUI
import Combine

final class LocalNotifications: NSObject, ObservableObject {
  @Published var authorized = false

  private let center = UNUserNotificationCenter.current()


}
