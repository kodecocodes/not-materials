import SwiftUI

struct AcceptanceImage: View {
  let accepted: Bool

  var body: some View {
    if accepted {
      Image(systemName: "hand.thumbsup")
        .foregroundColor(.green)
    } else {
      Image(systemName: "hand.thumbsdown")
        .foregroundColor(.red)
    }
  }
}

struct AcceptanceImage_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      AcceptanceImage(accepted: true)
        .previewLayout(.fixed(width: 50, height: 50))
      AcceptanceImage(accepted: false)
        .previewLayout(.fixed(width: 50, height: 50))
    }
  }
}
