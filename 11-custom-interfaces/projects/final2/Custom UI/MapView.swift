import SwiftUI
import MapKit

struct MapView: View {
  let region: MKCoordinateRegion

  var body: some View {
    Map(coordinateRegion: .constant(region))
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(region: .init(
      center: .init(latitude: 37.334886, longitude: -122.008988),
      span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
  }
}
