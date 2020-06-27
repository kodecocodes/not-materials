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
import MapKit

final class LocationViewController: UIViewController, SegueHandlerType {
  @IBOutlet private weak var map: MKMapView!
  @IBOutlet private weak var address: UITextField!
  @IBOutlet private weak var doneButton: UIBarButtonItem!

  enum SegueIdentifier: String {
    case locationDetails
  }

  private let geocoder = CLGeocoder()
  private let metersPerMile = 1609.344
  private let locationManager = CLLocationManager()

  private var coordinate: CLLocationCoordinate2D?
  private var annotation: MKPointAnnotation?

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    address.becomeFirstResponder()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segueIdentifier(forSegue: segue) == .locationDetails,
      let destination = segue.destination as? LocationDetailsViewController,
      let coordinate = coordinate else {
        return
    }

    destination.coordinate = coordinate
  }

  private func showAddressOnMap(address: String) {
    geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
      guard let self = self else { return }

      guard error == nil else {
        UIAlertController.okWithMessage("Address lookup failed.", presentingViewController: self)
        return
      }

      guard let placemark = placemarks?.first,
        let coordinate = placemark.location?.coordinate else {
          UIAlertController.okWithMessage("No available region found.", presentingViewController: self)
          return
      }

      self.coordinate = coordinate

      if let annotation = self.annotation {
        self.map.removeAnnotation(annotation)
      }

      self.annotation = MKPointAnnotation()
      self.annotation!.coordinate = coordinate

      if let thoroughfare = placemark.thoroughfare {
        if let subThoroughfare = placemark.subThoroughfare {
          self.annotation!.title = "\(subThoroughfare) \(thoroughfare)"
        } else {
          self.annotation!.title = thoroughfare
        }
      } else {
        self.annotation!.title = address
      }

      self.map.addAnnotation(self.annotation!)

      let viewRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: self.metersPerMile, longitudinalMeters: self.metersPerMile)
      self.map.setRegion(viewRegion, animated: true)
    }
  }

  @IBAction private func searchButtonPressed() {
    guard let addressToSearchFor = address.toTrimmedString() else {
        UIAlertController.okWithMessage("Please enter an address.", presentingViewController: self)
        return
    }

    address.resignFirstResponder()
    
    showAddressOnMap(address: addressToSearchFor)
  }

  @IBAction private func doneButtonTouched() {
    guard let _ = coordinate else {
      UIAlertController.okWithMessage("Please set a location first.", presentingViewController: self)
      return
    }

    performSegue(withIdentifier: .locationDetails, sender: self)
  }
}

extension LocationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchButtonPressed()
    textField.resignFirstResponder()

    return true
  }
}

extension LocationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    let authorized = status == .authorizedWhenInUse

    address.isEnabled = authorized
    doneButton.isEnabled = authorized

    if authorized {
      address.becomeFirstResponder()
    }
  }
}

