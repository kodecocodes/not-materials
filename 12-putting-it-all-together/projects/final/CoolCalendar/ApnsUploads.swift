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

extension AppDelegate {

  func registerForPushNotifications(application: UIApplication) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.badge, .sound, .alert]) {
      [weak self] granted, _ in

      guard granted else { return }

      center.delegate = self

      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
    }
  }

  func sendPushNotificationDetails(to urlString: String, using deviceToken: Data) {
    guard let url = URL(string: urlString) else {
      fatalError("Invalid URL string")
    }

    let token = deviceToken.reduce("") {
      $0 + String(format: "%02x", $1)
    }

    var obj: [String: Any] = [
      "token": token,
      "debug": false
    ]

    #if DEBUG
    obj["debug"] = true
    #endif

    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = try! JSONSerialization.data(withJSONObject: obj)

    #if DEBUG
    let pretty = try! JSONSerialization.data(withJSONObject: obj,
                                             options: .prettyPrinted)
    print("Device Token: \(token)")
    print(String(data: pretty, encoding: .utf8)!)
    #endif

//     URLSession.shared.dataTask(with: request).resume()
  }
}
