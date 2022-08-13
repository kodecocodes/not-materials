import SwiftUI

struct MapView: View {
  let mapImage: Image
  let targetImage: Image?

  var body: some View {
    mapImage
      .resizable()
      .aspectRatio(contentMode: .fit)
      .overlay(alignment: .topTrailing) {
        if let targetImage {
          targetImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80.0, height: 80.0)
        }
      }
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(mapImage: Image(systemName: "globe.americas"), targetImage: nil)
  }
}
