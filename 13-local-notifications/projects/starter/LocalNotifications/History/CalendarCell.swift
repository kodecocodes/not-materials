import SwiftUI

struct CalendarCell: View {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()
  
  private let title: String
  private let when: String
  
  init(for trigger: UNCalendarNotificationTrigger, with content: UNNotificationContent) {
    title = "Calendar - \(content.title)"
    
    let prefix = trigger.repeats ? "Every " : ""
    let date = Calendar.current.date(from: trigger.dateComponents)!
    when = "\(prefix) \(Self.dateFormatter.string(from: date))"
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
      
      Text(when)
        .font(.subheadline)
    }
  }
}
