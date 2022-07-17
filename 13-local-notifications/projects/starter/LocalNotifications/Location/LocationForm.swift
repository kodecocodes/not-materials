import SwiftUI
import MapKit
import Contacts
import Combine

struct LocationForm: View {
  @EnvironmentObject var commonFields: CommonFieldsModel
  @Environment(\.presentationMode) private var presentationMode
  @StateObject private var model = LocationLookupViewModel()

  let onComplete: (UNNotificationTrigger, CommonFieldsModel) async throws -> Void

  var body: some View {
    Form {
      Section(header: Text("Location specific notification data")) {
        HStack {
          TextField("Address", text: $model.address)

          Button {
            model.lookup(address: model.address)
          } label: {
            Image(systemName: "magnifyingglass")
              .imageScale(.large)
          }
          .popover(isPresented: $model.isShowingMap) {
            if let location = model.location {
              LocationValidationView(location: location) { coordinate in
                model.coordinate = coordinate
              }
            }
          }
        }

        TextField("Radius", text: $model.radius)
          .keyboardType(.decimalPad)

        Toggle(isOn: $model.notifyOnEntry) {
          Text("Notify on entry")
        }

        Toggle(isOn: $model.notifyOnExit) {
          Text("Notify on exit")
        }
      }

      CommonFields()
    }
    .textFieldStyle(RoundedBorderTextFieldStyle())
    .alert(item: $model.alertText) {
      Alert(title: Text($0.text), dismissButton: .default(Text("OK")))
    }
    .navigationBarItems(trailing:
      Button("Done", action: doneButtonTapped)
        .disabled(model.coordinate == nil))
    .navigationBarTitle(Text("Location Notification"))
  }

  private func doneButtonTapped() {
    Task { @MainActor in 
      let radiusStr = model.radius.trimmingCharacters(in: .whitespacesAndNewlines)

      guard !radiusStr.isEmpty, let distance = CLLocationDistance(radiusStr) else {
        model.alertText = AlertText(text: "Please specify numerical radius.")
        return
      }

      presentationMode.wrappedValue.dismiss()
    }
  }
}
