/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import UserNotifications
import UserNotificationsUI
import CalendarKit
import EventKit

class NotificationViewController: UIViewController, UNNotificationContentExtension {
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

    let size = CGSize(width: view.width, height: view.height)
    timelineContainer.frame = CGRect(origin: CGPoint.zero, size: size)
  }

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
      let id = userInfo["id"] as? Int
      else {
        return
      }
    
    calendarIdentifier = id

    var appointments = [
      addCalendarKitEvent(
      start: startDate,
      end: endDate,
      title: title)
    ]
    
    let calendar = Calendar.current
    let displayStart = calendar.date(
      byAdding: .hour,
      value: -2,
      to: startDate)!
    let displayEnd = calendar.date(
      byAdding: .hour,
      value: 2,
      to: endDate)!

    let predicate = eventStore.predicateForEvents(
      withStart: displayStart,
      end: displayEnd,
      calendars: nil)

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
    timelineContainer.scrollTo(hour24: Float(displayStart.hour))
  }
  
  func didReceive(
    _ response: UNNotificationResponse,
    completionHandler completion:
    @escaping (UNNotificationContentExtensionResponseOption)
    -> Void) {
    
    guard let choice =
      ActionIdentifier(rawValue: response.actionIdentifier)
    else {
      // This shouldn't happen but definitely don't crash.
      // Let the users report a bug that nothing happens
      // for this choice so you can fix it.
      completion(.doNotDismiss)
      return
    }

    switch choice {
    case .accept, .decline:
      completion(.dismissAndForwardAction)
    case .comment:
      becomeFirstResponder()
      keyboardTextField.becomeFirstResponder()
      completion(.doNotDismiss)
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

    Server.shared.commentOnInvitation(with: calendarIdentifier,
                                      comment: text)
    textField.text = nil

    keyboardTextField.resignFirstResponder()
    resignFirstResponder()

    return true
  }
}
