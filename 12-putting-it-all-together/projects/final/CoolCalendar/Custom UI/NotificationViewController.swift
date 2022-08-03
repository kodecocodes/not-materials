import UserNotifications
import UserNotificationsUI
import CalendarKit
import EventKit

class NotificationViewController: UIViewController {
  // swiftlint:disable:next implicitly_unwrapped_optional
  private var keyboardTextField: UITextField!
  private let eventStore = EKEventStore()
  private var calendarIdentifier: Int?

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override var inputAccessoryView: UIView? {
    return keyboardInputAccessoryView
  }

  private lazy var keyboardInputAccessoryView: UIView = {
    let keyboardHeight: CGFloat = 30
    let padding: CGFloat = 8

    let frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
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
    calendarKitEvent.dateInterval = .init(start: start, end: end)
    calendarKitEvent.text = title

    if let cgColor {
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

    let formatter = ISO8601DateFormatter()

    guard
      let userInfo = notification.request.content.userInfo as? [String: Any],
      let title = userInfo["title"] as? String, !title.isEmpty,
      let start = userInfo["start"] as? String,
      let startDate = formatter.date(from: start),
      let end = userInfo["end"] as? String,
      let endDate = formatter.date(from: end),
      let id = userInfo["id"] as? Int else {
      return
    }

    calendarIdentifier = id

    var appointments = [
      addCalendarKitEvent(start: startDate, end: endDate, title: title)
    ]

    let calendar = Calendar.current
    let displayStart = calendar.date(byAdding: .hour, value: -2, to: startDate)!
    let displayEnd = calendar.date(byAdding: .hour, value: 2, to: endDate)!

    let predicate = eventStore.predicateForEvents(
      withStart: displayStart,
      end: displayEnd,
      calendars: nil
    )

    appointments += eventStore
      .events(matching: predicate)
      .map {
        addCalendarKitEvent(
          start: $0.startDate,
          end: $0.endDate,
          title: $0.title,
          cgColor: $0.calendar.cgColor)
      }

    timelineContainer.timeline.date = startDate
    timelineContainer.timeline.layoutAttributes = appointments

    let hour = calendar.dateComponents([.hour], from: displayStart).hour!
    timelineContainer.scrollTo(hour24: Float(hour))
  }

  func didReceive(
    _ response: UNNotificationResponse
  ) async -> UNNotificationContentExtensionResponseOption {
    guard
      let choice = ActionIdentifier(rawValue: response.actionIdentifier)
    else {
      // This shouldn't happen but definitely don't crash.
      // Let the users report a bug that nothing happens
      // for this choice so you can fix it.
      return .doNotDismiss
    }

    switch choice {
    case .accept, .decline:
      return .dismissAndForwardAction
    case .comment:
      _ = becomeFirstResponder()
      _ = keyboardTextField.becomeFirstResponder()
      return .doNotDismiss
    }
  }
}

// MARK: - UITextFieldDelegate
extension NotificationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard
      textField == keyboardTextField,
      let text = textField.text,
      let calendarIdentifier = calendarIdentifier
    else {
      return true
    }

    Server.shared.commentOnInvitation(with: calendarIdentifier, comment: text)
    textField.text = nil

    keyboardTextField.resignFirstResponder()
    resignFirstResponder()
    return true
  }
}
