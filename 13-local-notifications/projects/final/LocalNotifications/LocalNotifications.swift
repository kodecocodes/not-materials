import SwiftUI
import Combine

@MainActor
final class LocalNotifications: NSObject, ObservableObject {
  @Published var authorized = false
  @Published var pending: [UNNotificationRequest] = []
  @Published var delivered: [UNNotification] = []

  private let center = UNUserNotificationCenter.current()

  override init() {
    super.init()
    center.delegate = self
  }

  func requestAuthorization() async throws {
    authorized = try await center.requestAuthorization(options: [.badge, .sound, .alert])
  }

  func refreshNotifications() async throws {
    pending = await center.pendingNotificationRequests()
    delivered = await center.deliveredNotifications()
  }

  func removePendingNotifications(identifiers: [String]) async throws {
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
    try await refreshNotifications()
  }

  func removeDeliveredNotifications(identifiers: [String]) async throws {
    center.removeDeliveredNotifications(withIdentifiers: identifiers)
    try await refreshNotifications()
  }

  func scheduleNotification(trigger: UNNotificationTrigger, model: CommonFieldsModel) async throws {
    let title = model.title.trimmingCharacters(in: .whitespacesAndNewlines)

    let content = UNMutableNotificationContent()
    content.title = title.isEmpty ? "No Title Provided" : title

    if model.hasSound {
      content.sound = UNNotificationSound.default
    }

    if let number = Int(model.badge) {
      content.badge = NSNumber(value: number)
    }

    let identifier = UUID().uuidString
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger)

    try await center.add(request)
  }
}

extension LocalNotifications: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    return [.banner, .badge, .sound]
  }
}
