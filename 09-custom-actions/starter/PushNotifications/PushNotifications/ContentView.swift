import SwiftUI
import CoreData

struct ContentView: View {
  @FetchRequest(entity: Message.entity(), sortDescriptors: [
    NSSortDescriptor(keyPath: \Message.received, ascending: true)
  ])
  var messages: FetchedResults<Message>

  @EnvironmentObject var notificationCenter: NotificationCenter

  private func image(for message: Message) -> Image {
    guard
      let image = message.image,
      let uiImage = UIImage(data: image) else {
        return Image(systemName: "photo")
      }

    return Image(uiImage: uiImage)
  }

  var body: some View {
    NavigationView {
      VStack {
        List(messages) { message in
          HStack {
            image(for: message)
              .resizable()
              .frame(width: 96, height: 54)

            Text(message.text ?? "")
              .font(.headline)
          }
        }

        NavigationLink(
          destination: BeachView(),
          isActive: $notificationCenter.isBeachViewActive) {
            EmptyView()
          }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
