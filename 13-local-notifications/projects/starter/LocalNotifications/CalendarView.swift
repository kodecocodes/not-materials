import SwiftUI

struct CalendarView: View {
  @Environment(\.presentationMode) private var presentationMode
  @EnvironmentObject var commonFields: CommonFieldsModel

  @State private var hours = ""
  @State private var minutes = ""
  @State private var seconds = ""
  @State private var alert = false

  let onComplete: (UNNotificationTrigger, CommonFieldsModel) -> Void

  var body: some View {
    Form {
      TextField("Hours", text: $hours)
        .keyboardType(.numberPad)

      TextField("Minutes", text: $minutes)
        .keyboardType(.numberPad)

      TextField("Seconds", text: $seconds)
        .keyboardType(.numberPad)

      CommonFields()
    }
    .alert(isPresented: $alert) {
      Alert(
        title: Text("Please specify hours, minutes and/or seconds."),
        dismissButton: .default(Text("OK")))
    }
    .navigationBarItems(trailing: Button("Done", action: doneButtonTapped))
    .navigationBarTitle(Text("Calendar Notification"))
  }

  private func doneButtonTapped() {
    var components = DateComponents()
    components.second = seconds.toInt(minimum: 1, maximum: 59)
    components.minute = minutes.toInt(minimum: 1, maximum: 59)
    components.hour = hours.toInt(minimum: 1, maximum: 23)

    guard !(components.second == nil && components.minute == nil && components.hour == nil) else {
      alert.toggle()
      return
    }

    presentationMode.wrappedValue.dismiss()
  }
}

struct CalendarView_Previews: PreviewProvider {
  static var previews: some View {
    CalendarView { _, _ in return }
  }
}
