import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image("swift-james-bond")
        .resizable()
        .frame(width: 211, height: 211)
      Text("Super Secret Communicator")
        .font(.title2)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
