import SwiftUI

struct ContentView: View {
  @State var accepted = 0
  @State var rejected = 0

  var body: some View {
    HStack {
      ColoredCounter(count: $accepted, backgroundColor: .green, text: "Accepted")
      ColoredCounter(count: $rejected, backgroundColor: .red, text: "Rejected")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
