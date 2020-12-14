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

  func lookup(address: String) {
    location = nil
    geocoder.lookup(address: address)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
        case .failure(let error):
          switch error {
          case .noCoordinates:
            self.alertText = AlertText(text: "Coordinates not found.")
          case .other(let genericError):
            self.alertText = AlertText(text: genericError.localizedDescription)
          }
        default:
          break
        }
      } receiveValue: { coordinates in
        self.coordinate = coordinates
        self.location = Location(coordinate: coordinates)
      }
      .store(in: &cancellableSet)
  }
}
