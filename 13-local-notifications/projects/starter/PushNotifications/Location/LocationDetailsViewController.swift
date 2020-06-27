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
import CoreLocation
import UserNotifications

final class LocationDetailsViewController: UIViewController, NotificationScheduler {
  @IBOutlet private weak var radius: UITextField!
  @IBOutlet private weak var notificationTitle: UITextField!
  @IBOutlet private weak var badge: UITextField!
  @IBOutlet private weak var repeats: UISwitch!
  @IBOutlet private weak var notifyOnExit: UISwitch!
  @IBOutlet private weak var notifyOnEntry: UISwitch!
  @IBOutlet private weak var sound: UISwitch!

  private let numberFormatter = NumberFormatter()

  var coordinate: CLLocationCoordinate2D!

  @IBAction private func toggled() {
    view.endEditing(true)
  }

  @IBAction private func doneButtonTouched(_ sender: UIBarButtonItem) {
    guard let radiusStr = radius.toTrimmedString(), let distance = CLLocationDistance(radiusStr) else {
        UIAlertController.okWithMessage("Please specify radius.", presentingViewController: self)
        return
    }


  }
}

extension LocationDetailsViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard textField !== notificationTitle, !string.isEmpty, let oldText = textField.text else { return true }

    let range = Range(range, in: oldText)!
    let newText = oldText.replacingCharacters(in: range, with: string)

    if textField === radius {
      guard let value = numberFormatter.number(from: newText), value.doubleValue > 0 else {
          return false
      }
    } else if textField === badge {
      guard let value = Int(newText), value >= 0 else {
        return false
      }
    }

    return true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case radius:
      notificationTitle.becomeFirstResponder()
    case notificationTitle:
      badge.becomeFirstResponder()
    case badge:
      textField.resignFirstResponder()
    default:
      break
    }

    return false
  }
}

