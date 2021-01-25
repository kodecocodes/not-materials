import SwiftUI

struct ColoredCounter: View {
  @Binding public var count: Int
  let backgroundColor: Color
  let text: String

  var body: some View {
    VStack {
      Rectangle()
        .fill(backgroundColor)
        .overlay(Text("\(count)").font(.title))
        .frame(width: 150, height: 150)
      Text(text)
    }
  }
}

#if false
struct ColoredCounter_Previews: PreviewProvider {
  static var previews: some View {
    ColoredCounter()
  }
}
#endif
