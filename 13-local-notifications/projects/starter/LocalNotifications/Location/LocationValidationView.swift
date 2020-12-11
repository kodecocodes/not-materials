import SwiftUI
import MapKit

let oneMile = Measurement(value: 1, unit: UnitLength.miles)
  .converted(to: .meters)
  .value

struct LocationValidationView: View {
  @Environment(\.presentationMode) private var presentationMode
  @State private var region: MKCoordinateRegion

  private let location: Location

  let onComplete: (CLLocationCoordinate2D?) -> Void

  init(location: Location, onComplete: @escaping (CLLocationCoordinate2D?) -> Void) {
    self.location = location
    _region = State(initialValue: MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: oneMile,
      longitudinalMeters: oneMile))

    self.onComplete = onComplete
  }

  var body: some View {
    NavigationView {
      Map(coordinateRegion: $region, annotationItems: [location]) {
        MapPin(coordinate: $0.coordinate, tint: .green)
      }
      .edgesIgnoringSafeArea([.horizontal, .bottom])
      .toolbar(content: {
        ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
          Button {
            onComplete(location.coordinate)
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("Correct")
          }
        }
        ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
          Button {
            onComplete(nil)
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("Incorrect")
          }
        }
      })
    }
  }
}

struct LocationValidationView_Previews: PreviewProvider {
  static var previews: some View {
    let location = Location(coordinate: .init(latitude: 37.33467830, longitude: -122.0089754000))
    LocationValidationView(location: location) { _ in return }
  }
}
