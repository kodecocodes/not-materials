import UserNotifications

class NotificationService: UNNotificationServiceExtension {
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler

    guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
      return
    }

    guard
      let urlPath = request.content.userInfo["media-url"] as? String,
      let url = URL(string: urlPath)
    else {
      contentHandler(bestAttemptContent)
      return
    }

    URLSession.shared.dataTask(with: url) { data, response, _ in
      defer { contentHandler(bestAttemptContent) }

      guard let data else { return }

      let destination = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(response?.suggestedFilename ?? url.lastPathComponent)

      do {
        try data.write(to: destination)

        bestAttemptContent.attachments = [
          try .init(identifier: "", url: destination)
        ]
      } catch {
      }
    }.resume()
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler, let bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
}
