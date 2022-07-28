import SwiftUI
import CoreData

struct ContentView: View {
  @FetchRequest(entity: Message.entity(), sortDescriptors: [
    NSSortDescriptor(keyPath: \Message.received, ascending: true)
  ])
  var messages: FetchedResults<Message>

  @EnvironmentObject var notificationCenter: NotificationCenter

  @State private var path: [Message] = []

  private func image(for message: Message) -> Image {
    guard
      let image = message.image,
      let uiImage = UIImage(data: image)
    else {
        return Image(systemName: "photo")
      }

    return Image(uiImage: uiImage)
  }

  var body: some View {
    NavigationStack(path: $path) {
      VStack {
        List(messages) { message in
          HStack {
            image(for: message)
              .resizable()
              .frame(width: 96, height: 54)

            NavigationLink(message.text ?? "", value: message)
          }
        }
        .navigationDestination(for: Message.self) { message in
          BeachView()
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
