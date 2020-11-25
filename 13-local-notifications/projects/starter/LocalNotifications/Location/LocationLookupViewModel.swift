import SwiftUI
import CoreLocation
import Combine
import Contacts

final class LocationLookupViewModel: ObservableObject {
  @Published var address = ""
  @Published var alertText: AlertText?
  @Published var radius = ""
  @Published var notifyOnEntry = true
  @Published var notifyOnExit = true
  @Published var searching = false
  @Published var isShowingMap = false
  @Published var location: Location? {
    didSet {
      isShowingMap = location != nil
    }
  }

  @Published var coordinate: CLLocationCoordinate2D?

  private let geocoder = Geocoder()
  private var cancellableSet: Set<AnyCancellable> = []

  init() {
    geocoder.$error
      .compactMap {
        if let text = $0 {
          return AlertText(text: text)
        } else {
          return nil
        }
      }
      .receive(on: RunLoop.main)
      .assign(to: \.alertText, on: self)
      .store(in: &cancellableSet)

    geocoder.$placemark
      .compactMap {
        guard let coord = $0?.location?.coordinate else {
          return nil
        }

        return Location(coordinate: coord)
      }
      .receive(on: RunLoop.main)
      .assign(to: \.location, on: self)
      .store(in: &cancellableSet)
  }

  func lookup(address: String) {
    location = nil
    geocoder.lookup(address: address)
  }
}
