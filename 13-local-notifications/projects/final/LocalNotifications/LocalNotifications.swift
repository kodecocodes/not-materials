import SwiftUI
import Combine

final class LocalNotifications: NSObject, ObservableObject {
  @Published var authorized = false
  @Published var pending: [UNNotificationRequest] = []
  @Published var delivered: [UNNotification] = []

  private let center = UNUserNotificationCenter.current()

  override init() {
    super.init()
    center.delegate = self
  }

  func requestAuthorization() {
    center.requestAuthorization(options: [.badge, .sound, .alert]) {
      [weak self] granted, error in

      if let error = error {
        print(error.localizedDescription)
      }

      DispatchQueue.main.async {
        self?.authorized = granted
      }
    }
  }

  func refreshNotifications() {
    center.getPendingNotificationRequests { requests in
      DispatchQueue.main.async {
        self.pending = requests
      }
    }

    center.getDeliveredNotifications { delivered in
      DispatchQueue.main.async {
        self.delivered = delivered
      }
    }
  }

  func removePendingNotifications(identifiers: [String]) {
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
    refreshNotifications()
  }

  func removeDeliveredNotifications(identifiers: [String]) {
    center.removeDeliveredNotifications(withIdentifiers: identifiers)
    refreshNotifications()
  }

  func scheduleNotification(
    trigger: UNNotificationTrigger,
    model: CommonFieldsModel,
    onError: @escaping (String) -> Void
  ) {
    let t = model.title.trimmingCharacters(in: .whitespacesAndNewlines)

    let content = UNMutableNotificationContent()
    content.title = t.isEmpty ? "No Title Provided" : t

    if model.hasSound {
      content.sound = UNNotificationSound.default
    }

    if let number = Int(model.badge) {
      content.badge = NSNumber(value: number)
    }

    let identifier = UUID().uuidString
    let request = UNNotificationRequest(identifier: identifier,
                                        content: content,
                                        trigger: trigger)

    center.add(request) { error in
      guard let error = error else { return }

      DispatchQueue.main.async {
        onError(error.localizedDescription)
      }
    }
  }
}

extension LocalNotifications: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .badge, .sound])
  }
}
