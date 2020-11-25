//

import SwiftUI

struct TimeCell: View {
  static let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .short
    return formatter
  }()
  
  private let title: String
  private let subTitle: String
  
  init(for trigger: UNTimeIntervalNotificationTrigger, with content: UNNotificationContent) {
    title = "Interval - \(content.title)"
    
    let prefix = trigger.repeats ? "Every " : ""
    subTitle = "\(prefix) \(Self.formatter.string(from: trigger.timeInterval)!)"
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
      
      Text(subTitle)
        .font(.subheadline)
    }
  }
}

