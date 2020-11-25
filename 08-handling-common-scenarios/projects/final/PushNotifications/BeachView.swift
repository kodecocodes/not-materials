import SwiftUI

struct BeachView: View {
  var body: some View {
    VStack {
      Image("background_beach")
      Text("Wish you were here!")
        .font(.title)

      Spacer()
    }
  }
}

struct BeachView_Previews: PreviewProvider {
  static var previews: some View {
    BeachView()
  }
}
