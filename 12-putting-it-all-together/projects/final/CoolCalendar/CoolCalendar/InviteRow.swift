import SwiftUI
import CoreData

private let dateFormatter: DateIntervalFormatter = {
  let formatter = DateIntervalFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  return formatter
}()

struct InviteRow: View {
  let invite: Invite

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        AcceptanceImage(accepted: invite.accepted)
        Text(invite.title!)
          .font(.headline)
      }
      Text(dateFormatter.string(from: invite.start!, to: invite.end!))
        .font(.subheadline)
    }
  }
}

struct InviteRow_Previews: PreviewProvider {
  static var previews: some View {
    let invite = Invite(context: PersistenceController.preview.container.viewContext)
    invite.title = "Event Name"
    invite.accepted = true
    invite.start = Date()
    invite.end = Date().addingTimeInterval(3600)

    return InviteRow(invite: invite)
      .previewLayout(.fixed(width: 300, height: 100))
  }
}
