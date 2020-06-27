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


final class ViewController: UITableViewController, SegueHandlerType {
  @IBOutlet private weak var addButton: UIBarButtonItem!
  @IBOutlet private weak var refreshButton: UIBarButtonItem!

  enum SegueIdentifier : String {
    case timed, calendar, location
  }

  private let center = UNUserNotificationCenter.current()
  private var pending: [UNNotificationRequest] = []
  private var delivered: [UNNotification] = []

  private lazy var measurementFormatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .medium
    formatter.unitOptions = .naturalScale
    return formatter
  }()

  private lazy var dateComponentsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .short
    return formatter
  }()

  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()

  private func refreshNotificationList() {

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)


  }

  private func configure(cell: UITableViewCell, with trigger: UNNotificationTrigger?, and content: UNNotificationContent?) {
    guard let content = content, trigger != nil else {
      cell.textLabel?.text = "None"
      cell.detailTextLabel?.text = ""
      return
    }

    if let trigger = trigger as? UNCalendarNotificationTrigger {
      cell.textLabel?.text = "Calendar - \(content.title)"

      let prefix = trigger.repeats ? "Every " : ""
      let when = Calendar.current.date(from: trigger.dateComponents)!
      cell.detailTextLabel?.text = prefix + dateFormatter.string(from: when)
    } else if let trigger = trigger as? UNTimeIntervalNotificationTrigger {
      cell.textLabel?.text = "Interval - \(content.title)"

      let prefix = trigger.repeats ? "Every " : ""
      cell.detailTextLabel?.text = prefix + dateComponentsFormatter.string(from: trigger.timeInterval)!
    } else if let trigger = trigger as? UNLocationNotificationTrigger {
      cell.textLabel?.text = "Location - \(content.title)"

      let region = trigger.region as! CLCircularRegion

      let measurement = Measurement(value: region.radius, unit: UnitLength.meters)
      let radius = measurementFormatter.string(from: measurement)

      cell.detailTextLabel?.text = "ɸ \(region.center.latitude), λ \(region.center.longitude), radius \(radius)"
    }
  }

  @IBAction private func addButtonPressed() {
    let timed = UIAlertAction(title: "Timed", style: .default) { [weak self] _ in
      self?.performSegue(withIdentifier: .timed, sender: nil)
    }

    let calendar = UIAlertAction(title: "Calendar", style: .default) { [weak self] _ in
      self?.performSegue(withIdentifier: .calendar, sender: nil)
    }

    let location = UIAlertAction(title: "Location", style: .default) { [weak self] _ in
      self?.performSegue(withIdentifier: .location, sender: nil)
    }

    let alert = UIAlertController(title: "Type of trigger", message: "Please select the type of local notification you'd like to create.", preferredStyle: .actionSheet)
    alert.addAction(timed)
    alert.addAction(calendar)
    alert.addAction(location)

    present(alert, animated: true, completion: nil)
  }

  @IBAction private func refreshButtonPressed() {
    refreshNotificationList()
  }
}

// MARK: - UITableViewDataSource
extension ViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0, !pending.isEmpty {
      return pending.count
    } else if section == 1, !delivered.isEmpty {
      return delivered.count
    } else {
      return 1
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)

    if indexPath.section == 0, !pending.isEmpty {
      configure(cell: cell, with: pending[indexPath.row].trigger, and: pending[indexPath.row].content)
    } else if indexPath.section == 1, !delivered.isEmpty {
      configure(cell: cell, with: delivered[indexPath.row].request.trigger, and: delivered[indexPath.row].request.content)
    } else {
      configure(cell: cell, with: nil, and: nil)
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }

    if indexPath.section == 0 {
      guard !pending.isEmpty else { return }

      let request = pending[indexPath.row]

    } else {
      guard !delivered.isEmpty else { return }

      let request = delivered[indexPath.row].request

    }

    refreshNotificationList()
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Pending" : "Delivered"
  }
}

extension ViewController: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

    refreshNotificationList()

    completionHandler([.alert, .sound, .badge])
  }
}
