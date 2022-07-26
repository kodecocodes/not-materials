import SwiftUI
import MapKit

struct MapView: View {
  let region: MKCoordinateRegion
  let locationName: String?

  var body: some View {
    VStack {
      Map(coordinateRegion: .constant(region))

      if let locationName {
        Text(locationName)
          .font(.title)
      }
    }
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(region: .init(
      center: .init(latitude: 37.334886, longitude: -122.008988),
      span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ), locationName: "This is a test")
  }
}
