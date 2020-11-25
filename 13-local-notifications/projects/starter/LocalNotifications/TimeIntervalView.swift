import SwiftUI

struct TimeIntervalView: View {
  @Environment(\.presentationMode) private var presentationMode
  @EnvironmentObject var model: CommonFieldsModel
  
  @State private var seconds = ""
  @State private var alert = false
  
  let onComplete: (UNNotificationTrigger, CommonFieldsModel) -> Void
  
  var body: some View {
    Form {
      TextField("Seconds to wait", text: $seconds)
        .keyboardType(.numberPad)
      
      CommonFields()
    }
    .alert(isPresented: $alert) {
      Alert(title: Text("Please enter a positive numeric value for the seconds to wait."),
            dismissButton: .default(Text("OK")))
    }
    .navigationBarItems(trailing: Button("Done") { doneButtonTouched() })
    .navigationBarTitle(Text("Timed Notification"))
  }
  
  private func doneButtonTouched() {
    let value = seconds.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    guard !value.isEmpty, let interval = TimeInterval(value), interval > 0 else {
      alert.toggle()
      return
    }
    
    presentationMode.wrappedValue.dismiss()
  }
}

struct TimeIntervalView_Previews: PreviewProvider {
  static var previews: some View {
    TimeIntervalView() { _,_  in return }
  }
}
