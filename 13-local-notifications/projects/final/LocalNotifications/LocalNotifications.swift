import SwiftUI
import Combine

@MainActor
final class LocalNotifications: NSObject, ObservableObject {
  @Published var authorized = false
  @Published var pending: [UNNotificationRequest] = []
  @Published var delivered: [UNNotification] = []

  override init() {
    super.init()
    center.delegate = self
  }

  private let center = UNUserNotificationCenter.current()

  func requestAuthorization() async throws {
    authorized = try await center.requestAuthorization(options: [.badge, .sound, .alert])
  }

  @MainActor
  func refreshNotifications() async {
    pending = await center.pendingNotificationRequests()
    delivered = await center.deliveredNotifications()
  }

  func removePendingNotifications(identifiers: [String]) async {
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
    await refreshNotifications()
  }

  func removeDeliveredNotifications(identifiers: [String]) async {
    center.removeDeliveredNotifications(withIdentifiers: identifiers)
    await refreshNotifications()
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
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.banner, .badge, .sound]
  }
}
