import SwiftUI
import CoreData
import EventKit

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State private var askForCalendarPermissions = false
  @State private var eventStore = EKEventStore()

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Invite.start, ascending: true)],
    animation: .default
  )
  private var invites: FetchedResults<Invite>

  var body: some View {
    List(invites) { InviteCellView(invite: $0) }
      .onAppear(perform: onAppear)
      .actionSheet(isPresented: $askForCalendarPermissions, content: actionSheet)
  }

  private func onAppear() {
    let status = EKEventStore.authorizationStatus(for: .event)

    switch (status) {
    case .notDetermined:
      eventStore.requestAccess(to: .event) {
        granted, _ in
        guard !granted else { return }
        askForCalendarPermissions = true
      }

    case .authorized:
      break

    default:
      askForCalendarPermissions = true
    }
  }

  private func actionSheet() -> ActionSheet {
    return ActionSheet(title: Text("This application requires calendar access"),
                       message: Text("Grant access?"),
                       buttons: [
                        .default(Text("Settings")) {
                          let str = UIApplication.openSettingsURLString
                          UIApplication.shared.open(URL(string: str)!)
                        },
                        .cancel()
                       ])
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
