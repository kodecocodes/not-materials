import SwiftUI

struct ContentView: View {
  @ObservedObject var counter = Counter.shared

  var body: some View {
    HStack {
      ColoredCounter(
        count: $counter.accepted,
        backgroundColor: .green,
        text: "Accepted")
      
      ColoredCounter(
        count: $counter.rejected,
        backgroundColor: .red,
        text: "Rejected")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
