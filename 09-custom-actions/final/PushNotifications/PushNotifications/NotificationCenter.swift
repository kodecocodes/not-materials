import UserNotifications

public let categoryIdentifier = "AcceptOrReject"

public enum ActionIdentifier: String {
  case accept, reject
}

final class NotificationCenter: NSObject {
  @Published var isBeachViewActive = false

  func registerCustomActions() {
    let accept = UNNotificationAction(
      identifier: ActionIdentifier.accept.rawValue,
      title: "Accept")

    let reject = UNNotificationAction(
      identifier: ActionIdentifier.reject.rawValue,
      title: "Reject")

    let category = UNNotificationCategory(
      identifier: categoryIdentifier,
      actions: [accept, reject],
      intentIdentifiers: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
  }
}

extension NotificationCenter: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.banner, .sound, .badge]
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    let content = response.notification.request.content

    if content.userInfo["beach"] != nil {
      // In a real app you'd likely pull a URL from the beach data
      // and use that image.
      isBeachViewActive = true
    }

    guard categoryIdentifier == content.categoryIdentifier,
      let action = ActionIdentifier(rawValue: response.actionIdentifier)
    else {
      return
    }

    switch action {
    case .accept: Counter.shared.accepted += 1
    case .reject: Counter.shared.rejected += 1
    }
  }
}

extension NotificationCenter: ObservableObject {
}
