import SwiftUI
import MapKit

struct MapView: View {
  let region: MKCoordinateRegion
  let image: Image?

  var body: some View {
    Map(coordinateRegion: .constant(region))
      .overlay(alignment: .topTrailing) {
        if let image {
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80.0, height: 80.0)
        }
      }
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(region: .init(
      center: .init(latitude: 37.334886, longitude: -122.008988),
      span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ), image: nil)
  }
}
