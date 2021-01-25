import UserNotifications
import CoreData

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound, .badge])
  }

  private func createInvite(with title: String, starting: Date, ending: Date, accepted: Bool) {
    let context = PersistenceController.shared.container.viewContext
    context.perform {
      let invite = Invite(context: context)
      invite.title = title
      invite.start = starting
      invite.end = ending
      invite.accepted = accepted

      try? context.save()
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    defer { completionHandler() }

    let formatter = ISO8601DateFormatter()
    let content = response.notification.request.content

    guard
      let choice = ActionIdentifier(rawValue: response.actionIdentifier),
      let userInfo = content.userInfo as? [String: Any],
      let title = userInfo["title"] as? String, !title.isEmpty,
      let start = userInfo["start"] as? String,
      let startDate = formatter.date(from: start),
      let end = userInfo["end"] as? String,
      let endDate = formatter.date(from: end),
      let calendarIdentifier = userInfo["id"] as? Int else {
        return
    }

    switch choice {
    case .accept:
      Server.shared.acceptInvitation(with: calendarIdentifier)
      createInvite(
        with: title,
        starting: startDate,
        ending: endDate,
        accepted: true)

    case .decline:
      Server.shared.declineInvitation(with: calendarIdentifier)
      createInvite(
        with: title,
        starting: startDate,
        ending: endDate,
        accepted: false)

    default:
      break
    }
  }
}
