import SwiftUI

struct CommonFields: View {
  @EnvironmentObject var model: CommonFieldsModel

  var body: some View {
    Section(header: Text("Common to all notifications")) {
      TextField("Title", text: $model.title)
      TextField("Badge", text: $model.badge)
        .keyboardType(.numberPad)

      Toggle(isOn: $model.isRepeating) {
        Text("Repeats")
      }

      Toggle(isOn: $model.hasSound) {
        Text("Play sound")
      }
    }
  }
}

struct CommonFields_Previews: PreviewProvider {
  static var previews: some View {
    CommonFields()
      .environmentObject(CommonFieldsModel())
  }
}
