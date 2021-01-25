import SwiftUI
import UserNotifications

struct ContentView: View {
  enum SheetType {
    case timed, calendar, location
  }

  @EnvironmentObject var commonFields: CommonFieldsModel
  @State private var showActionSheet = false
  @State private var showSheet = false
  @State private var alertText: AlertText?
  @State private var sheetType = SheetType.timed

  var body: some View {
    NavigationView {
      Group {
      }
      .navigationBarTitle("Notifications")
      .navigationBarItems(trailing: Button {
        commonFields.reset()
        showActionSheet.toggle()
      } label: {
        Image(systemName: "plus")
      })
    }
    .actionSheet(isPresented: $showActionSheet) {
      ActionSheet(
        title: Text("Type of trigger"),
        message: Text("Please select the type of local notification you'd like to create"),
        buttons: [
          actionSheetButton(text: "Calendar", type: .calendar),
          actionSheetButton(text: "Location", type: .location),
          actionSheetButton(text: "Timed", type: .timed)
        ])
    }
    .sheet(isPresented: $showSheet) {
      //      localNotifications.refreshNotifications()
    } content: {
      NavigationView {
        switch sheetType {
        case .calendar:
          CalendarView(onComplete: scheduleNotification)
        case .timed:
          TimeIntervalView(onComplete: scheduleNotification)
        case .location:
          LocationLookupView(onComplete: scheduleNotification)
        }
      }
    }
    .alert(item: $alertText) {
      Alert(
        title: Text("Notification not scheduled."),
        message: Text($0.text),
        dismissButton: .default(Text("OK")))
    }
  }

  private func actionSheetButton(text: String, type: SheetType) -> Alert.Button {
    return .default(Text(text)) {
      sheetType = type
      showSheet.toggle()
    }
  }

  private func scheduleNotification(trigger: UNNotificationTrigger, model: CommonFieldsModel) {
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
