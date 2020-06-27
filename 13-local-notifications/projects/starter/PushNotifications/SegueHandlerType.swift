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

/**
 * A protocol that represents a segue identifier in the storyboard.  Every view controller that
 * inherits this protocol should define the `SegueIdentifier` enum to be of type `String`, and
 * there should be a case name that **exactly** matches what is in the storyboard.
 *
 * ```swift
 * class SomeViewController : UIViewController, SegueHandlerType {
 *   enum SegueIdentifier : String {
 *     case ShowSomething, ReturnHome
 *   }
 *
 *   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 *     guard let ident = segueIdentifier(forSegue: segue) else { return }
 *
 *     switch ident {
 *     case .ShowSomething: ...
 *     case .ReturnHome: ...
 *     }
 *   }
 *
 *   @IBAction private someAction() {
 *     ...
 *     performSegue(withIdentifier: .ShowSomething, sender: self)
 *   }
 * }
 */
@available(iOS 9.0, OSX 10.10, *)
protocol SegueHandlerType {
  associatedtype SegueIdentifier: RawRepresentable
}

@available(iOS 9.0, OSX 10.10, *)
extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
  func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
    performSegue(withIdentifier: identifier.rawValue, sender: sender)
  }

  func segueIdentifier(forSegue segue: UIStoryboardSegue) -> SegueIdentifier? {
    // It's quite possible to have no identifier.
    guard let identifier = segue.identifier else { return nil }

    return SegueIdentifier(rawValue: identifier)
  }

  func shouldPerformSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) -> Bool {
    return shouldPerformSegue(withIdentifier: identifier.rawValue, sender: sender)
  }
}
