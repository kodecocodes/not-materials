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
import CoreData
import EventKit

final class ViewController: UITableViewController {
  var managedObjectContext: NSManagedObjectContext!
  
  private let eventStore = EKEventStore()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let status = EKEventStore.authorizationStatus(for: .event)

    switch (status) {
    case .notDetermined:
      eventStore.requestAccess(to: .event) {
        [weak self] granted, _ in
        guard !granted, let self = self else { return }

        self.askForAccess()
      }

    case .authorized:
      break

    default:
      askForAccess()
    }
  }

  private func askForAccess() {
    let alert = UIAlertController(
      title: nil,
      message: "This application requires calendar access",
      preferredStyle: .actionSheet)

    alert.addAction(UIAlertAction(
      title: "Settings",
      style: .default) { _ in
        let url = URL(
          string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url)
    })

    alert.addAction(UIAlertAction(
      title: "Cancel",
      style: .default))

    present(alert, animated: true)
  }

  lazy private var dateFormatter: DateIntervalFormatter = {
    let fmt = DateIntervalFormatter()
    fmt.dateStyle = .short
    fmt.timeStyle = .short

    return fmt
  }()

  lazy private var fetchedResultsController: NSFetchedResultsController<Invite> = {
    let request = Invite.fetchRequest() as NSFetchRequest<Invite>
    request.sortDescriptors = [
      NSSortDescriptor(key: #keyPath(Invite.start), ascending: false)
    ]

    let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self

    try! frc.performFetch()

    return frc
  }()
}


// MARK: - UITableViewDataSource
extension ViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let invite = fetchedResultsController.object(at: indexPath)

    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
    cell.textLabel?.text = invite.title
    cell.detailTextLabel?.text = dateFormatter.string(from: invite.start!, to: invite.end!)

    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }

    let invite = fetchedResultsController.object(at: indexPath)
    managedObjectContext.delete(invite)

    try? managedObjectContext.save()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections![section].numberOfObjects
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sectionInfo = fetchedResultsController.sections?[section],
      let accepted = Int(sectionInfo.name) else {
        return nil
    }

    return accepted == 1 ? "Accepted" : "Declined"
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.reloadData()
  }
}
