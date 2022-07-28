import UserNotifications
import CoreData

final class NotificationCenter: NSObject {
  private func createInvite(with title: String, starting: Date, ending: Date, accepted: Bool) async {
    let context = PersistenceController.shared.container.viewContext

    await context.perform(schedule: .enqueued) {
      let invite = Invite(context: context)
      invite.title = title
      invite.start = starting
      invite.end = ending
      invite.accepted = accepted

      try? context.save()
    }
  }
}

extension NotificationCenter: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.banner, .sound, .badge]
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
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
      await createInvite(with: title, starting: startDate, ending: endDate, accepted: true)

    case .decline:
      Server.shared.declineInvitation(with: calendarIdentifier)
      await createInvite(with: title, starting: startDate, ending: endDate, accepted: false)

    default:
      break
    }
  }
}
