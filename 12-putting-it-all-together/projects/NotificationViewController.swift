import UserNotifications
import UserNotificationsUI
import CalendarKit
import EventKit

class NotificationViewController: UIViewController {
  private var keyboardTextField: UITextField!

  private lazy var keyboardInputAccessoryView: UIView = {
    let keyboardHeight: CGFloat = 30
    let padding: CGFloat = 8

    let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width,
                       height: keyboardHeight + padding * 2)

    let view = UIView(frame: frame)
    view.backgroundColor = UIColor.lightGray

    let inset = frame.insetBy(dx: padding, dy: padding)
    keyboardTextField = UITextField(frame: inset)
    keyboardTextField.delegate = self
    keyboardTextField.layer.borderWidth = 1
    keyboardTextField.layer.borderColor = UIColor.black.cgColor
    keyboardTextField.layer.cornerRadius = 8
    keyboardTextField.layer.masksToBounds = true

    view.addSubview(keyboardTextField)

    return view
  }()

  private lazy var timelineContainer: TimelineContainer = {
    let timeline = TimelineView()
    timeline.frame.size.height = timeline.fullHeight

    let container = TimelineContainer(timeline)
    container.contentSize = timeline.frame.size
    container.addSubview(timeline)
    container.isUserInteractionEnabled = false

    return container
  }()

  func addCalendarKitEvent(start: Date, end: Date, title: String, cgColor: CGColor? = nil) -> EventLayoutAttributes {
    let calendarKitEvent = Event()
    calendarKitEvent.startDate = start
    calendarKitEvent.endDate = end
    calendarKitEvent.text = title

    if let cgColor = cgColor {
      calendarKitEvent.backgroundColor = UIColor(cgColor: cgColor)
    }

    return EventLayoutAttributes(calendarKitEvent)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let size = CGSize(width: view.frame.width, height: view.frame.height)
    timelineContainer.frame = CGRect(origin: CGPoint.zero, size: size)
  }
}

// MARK: - UNNotificationContentExtension
extension NotificationViewController: UNNotificationContentExtension {
  func didReceive(_ notification: UNNotification) {
    view.addSubview(timelineContainer)

//    timelineContainer.timeline.date = startDate
//    timelineContainer.timeline.layoutAttributes = appointments
//    
//    let hour = calendar.dateComponents([.hour], from: displayStart).hour!
//    timelineContainer.scrollTo(hour24: Float(hour))
  }
}

// MARK: - UITextFieldDelegate
extension NotificationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
}
