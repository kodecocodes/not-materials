import SwiftUI
import UserNotifications

struct HistoryCell: View {
  let trigger: UNNotificationTrigger?
  let content: UNNotificationContent

  init(for request: UNNotificationRequest) {
    trigger = request.trigger
    content = request.content
  }

  var body: some View {
    switch trigger {
    case let trigger as UNCalendarNotificationTrigger:
      CalendarCell(for: trigger, with: content)
    case let trigger as UNLocationNotificationTrigger:
      LocationCell(for: trigger, with: content)
    case let trigger as UNTimeIntervalNotificationTrigger:
      TimeCell(for: trigger, with: content)
    default:
      Text("Unknown trigger type.")
    }
  }
}
