import SwiftUI
import MapKit
import Contacts
import Combine

struct LocationForm: View {
  @EnvironmentObject var commonFields: CommonFieldsModel
  @Environment(\.presentationMode) private var presentationMode
  @StateObject private var model = LocationLookupViewModel()

  let onComplete: (UNNotificationTrigger, CommonFieldsModel) -> Void

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
            LocationValidationView(location: model.location!) { coordinate in
              model.coordinate = coordinate
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
      Alert(title: Text($0.text),
            dismissButton: .default(Text("OK")))
    }
    .navigationBarItems(trailing:
                          Button("Done", action: doneButtonTouched)
                          .disabled(model.coordinate == nil))
    .navigationBarTitle(Text("Location Notification"))
  }

  private func doneButtonTouched() {
    let radiusStr = model.radius.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !radiusStr.isEmpty, let distance = CLLocationDistance(radiusStr) else {
      model.alertText = AlertText(text: "Please specify numerical radius.")
      return
    }

    let region = CLCircularRegion(
      center: model.coordinate!,
      radius: distance,
      identifier: UUID().uuidString)

    region.notifyOnExit = model.notifyOnExit
    region.notifyOnEntry = model.notifyOnEntry

    let trigger = UNLocationNotificationTrigger(region: region, repeats: commonFields.isRepeating)
    onComplete(trigger, commonFields)
    
    presentationMode.wrappedValue.dismiss()
  }
}
