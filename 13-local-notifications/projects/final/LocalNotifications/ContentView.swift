import SwiftUI
import UserNotifications

struct ContentView: View {
  enum SheetType {
    case timed, calendar, location
  }

  @EnvironmentObject var commonFields: CommonFieldsModel
  @StateObject private var localNotifications = LocalNotifications()
  @State private var showActionSheet = false
  @State private var showSheet = false
  @State private var alertText: AlertText?
  @State private var sheetType = SheetType.timed

  var body: some View {
    NavigationView {
      Group {
        if !localNotifications.authorized {
          Text("This app only works when notifications are enabled.")
        } else {
          List {
            Section(header: Text("Pending")) {
              ForEach(localNotifications.pending, id: \.identifier) {
                HistoryCell(for: $0)
              }
              .onDelete(perform: removePendingNotifications)
            }
            Section(header: Text("Delivered")) {
              ForEach(localNotifications.delivered, id: \.request.identifier) {
                HistoryCell(for: $0.request)
              }
            }
          }
          .listStyle(GroupedListStyle())
        }
      }
      .navigationBarTitle("Notifications")
      .navigationBarItems(leading: EditButton(), trailing: Button {
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
      localNotifications.refreshNotifications()
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
    .onAppear(perform: localNotifications.requestAuthorization)
  }

  private func actionSheetButton(text: String, type: SheetType) -> Alert.Button {
    return .default(Text(text)) {
      sheetType = type
      showSheet.toggle()
    }
  }

  private func scheduleNotification(trigger: UNNotificationTrigger, model: CommonFieldsModel) {
    localNotifications.scheduleNotification(
      trigger: trigger,
      model: commonFields) {
      alertText = AlertText(text: $0)
    }
  }

  private func removePendingNotifications(at offsets: IndexSet) {
    let identifiers = offsets.map {
      localNotifications.pending[$0].identifier
    }

    localNotifications.removePendingNotifications(identifiers: identifiers)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
