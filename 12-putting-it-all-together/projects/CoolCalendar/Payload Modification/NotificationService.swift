import UserNotifications
import EventKit

class NotificationService: UNNotificationServiceExtension {
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard let bestAttemptContent = bestAttemptContent else {
      return
    }

    defer { contentHandler(bestAttemptContent) }

    if EKEventStore.authorizationStatus(for: .event) != .authorized {
      bestAttemptContent.categoryIdentifier = ""
    }

    updateBadge()
    updateText(request: request)
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

  private func updateBadge() {
    guard let bestAttemptContent = bestAttemptContent,
          let increment = bestAttemptContent.badge as? Int else { return }

    if increment == 0 {
      UserDefaults.appGroup.badge = 0
      bestAttemptContent.badge = 0
    } else {
      let current = UserDefaults.appGroup.badge
      let new = current + increment

      UserDefaults.appGroup.badge = new
      bestAttemptContent.badge = NSNumber(integerLiteral: new)
    }
  }

  private func updateText(request: UNNotificationRequest) {
    guard let bestAttemptContent = bestAttemptContent else { return }

    let formatter = ISO8601DateFormatter()
    let authStatus = EKEventStore.authorizationStatus(for: .event)

    guard authStatus == .authorized,
          let userInfo = request.content.userInfo as? [String: Any],
          let title = userInfo["title"] as? String,
          !title.isEmpty,
          let start = userInfo["start"] as? String,
          let startDate = formatter.date(from: start),
          let end = userInfo["end"] as? String,
          let endDate = formatter.date(from: end),
          userInfo["id"] as? Int != nil else {
      bestAttemptContent.categoryIdentifier = ""
      return
    }

    let rangeFormatter = DateIntervalFormatter()
    rangeFormatter.dateStyle = .short
    rangeFormatter.timeStyle = .short

    let range = rangeFormatter.string(from: startDate,
                                      to: endDate)
    bestAttemptContent.body = "\(title)\n\(range)"
  }
}
