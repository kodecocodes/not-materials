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
    if let trigger = trigger as? UNCalendarNotificationTrigger {
      CalendarCell(for: trigger, with: content)
    } else if let trigger = trigger as? UNLocationNotificationTrigger {
      LocationCell(for: trigger, with: content)
    } else if let trigger = trigger as? UNTimeIntervalNotificationTrigger {
      TimeCell(for: trigger, with: content)
    } else {
      Text("Unknown trigger type.")
    }
  }
}
