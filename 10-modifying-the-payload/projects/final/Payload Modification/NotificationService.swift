import UserNotifications

class NotificationService: UNNotificationServiceExtension {

  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard let bestAttemptContent = bestAttemptContent else {
      return
    }

    if let increment = bestAttemptContent.badge as? Int {
      if increment == 0 {
        UserDefaults.extensions.badge = 0
        bestAttemptContent.badge = 0
      } else {
        let current = UserDefaults.extensions.badge
        let new = current + increment

        UserDefaults.extensions.badge = new
        bestAttemptContent.badge = NSNumber(value: new)
      }
    }
    
    bestAttemptContent.title = ROT13.shared.decrypt(bestAttemptContent.title)
    bestAttemptContent.body = ROT13.shared.decrypt(bestAttemptContent.body)

    guard
      let urlPath = request.content.userInfo["media-url"] as? String,
      let url = URL(string: ROT13.shared.decrypt(urlPath))
    else {
      contentHandler(bestAttemptContent)
      return
    }

    URLSession.shared.dataTask(with: url) { data, response, _ in
      defer { contentHandler(bestAttemptContent) }

      guard let data = data else { return }

      let file = response?.suggestedFilename ?? url.lastPathComponent
      let destination = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(file)

      do {
        try data.write(to: destination)

        let attachment = try UNNotificationAttachment(
          identifier: "",
          url: destination)
        bestAttemptContent.attachments = [attachment]
      } catch {
      }
    }.resume()
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

}
