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

import UserNotifications
import EventKit

class NotificationService: UNNotificationServiceExtension {
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler:
    @escaping (UNNotificationContent) -> Void) {
    
    self.contentHandler = contentHandler
    bestAttemptContent = request.content.mutableCopy()
      as? UNMutableNotificationContent
    guard
      let bestAttemptContent = bestAttemptContent
    else { return }

    if EKEventStore.authorizationStatus(for: .event)
       != .authorized {
      bestAttemptContent.categoryIdentifier = ""
    }

    updateBadge()
    updateText(request: request)
    contentHandler(bestAttemptContent)
  }

  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
  
  private func updateBadge() {
    guard
      let bestAttemptContent = bestAttemptContent,
      let increment = bestAttemptContent.badge as? Int
    else { return }
    
    switch increment {
    case 0:
      UserDefaults.appGroup.badge = 0
      bestAttemptContent.badge = 0
    default:
      let current = UserDefaults.appGroup.badge
      let new = current + increment
      
      UserDefaults.appGroup.badge = new
      bestAttemptContent.badge = NSNumber(integerLiteral: new)
    }
  }
  
  private func updateText(request: UNNotificationRequest) {
    let formatter = ISO8601DateFormatter()
    
    guard let bestAttemptContent = bestAttemptContent else { return }

    let authStatus = EKEventStore.authorizationStatus(for: .event)
    
    guard authStatus == .authorized,
          let userInfo = request.content.userInfo as? [String : Any],
          let title = userInfo["title"] as? String,
          !title.isEmpty,
          let start = userInfo["start"] as? String,
          let startDate = formatter.date(from: start),
          let end = userInfo["end"] as? String,
          let endDate = formatter.date(from: end),
          userInfo["id"] as? Int != nil else {
      bestAttemptContent.categoryIdentifier = ""
      return
    }
    
    let rangeFormatter = DateIntervalFormatter()
    rangeFormatter.dateStyle = .short
    rangeFormatter.timeStyle = .short
    
    let range = rangeFormatter.string(from: startDate,
                                      to: endDate)
    bestAttemptContent.body = "\(title)\n\(range)"
  }
  
}
