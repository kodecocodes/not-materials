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

extension UIAlertController {
    class func okWithMessage(_ message: String, presentingViewController: UIViewController?, completion: (() -> Void)? = nil, onOK: ((UIAlertAction?) -> Void)? = nil) {
        let vc: UIViewController?

        if let presentingViewController = presentingViewController {
            vc = presentingViewController
        } else {
            vc = UIApplication.shared.keyWindow?.rootViewController
        }

        if let presentingViewController = vc {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addOKButton(onOK)

            presentingViewController.present(alert, animated: true, completion: completion)
        }
    }

    class func cancelWithMessage(_ message: String, presentingViewController: UIViewController?, completion: (() -> Void)? = nil, onOK: ((UIAlertAction?) -> Void)? = nil) {
        if let presentingViewController = presentingViewController {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

            alert.addOKButton(onOK)
            alert.addCancelButton()

            presentingViewController.present(alert, animated: true, completion: completion)
        }
    }

    func addCancelButton() {
        let cancel = NSLocalizedString("Cancel", comment: "The cancel button")
        self.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
    }

    func addOKButton(_ handler: ((UIAlertAction?) -> Void)? = nil) {
        let ok = NSLocalizedString("OK", comment: "The OK button")
        self.addAction(UIAlertAction(title: ok, style: .default, handler: handler))
    }

    func addCancelOKButtons(_ handler: ((UIAlertAction?) -> Void)? = nil) {
        addCancelButton()
        addOKButton(handler)
    }
}
