import SwiftUI
import CoreLocation

@main
struct LocalNotificationsApp: App {
  private let commonFieldsModel = CommonFieldsModel()
  private let locationManager = LocationManager()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(commonFieldsModel)
        .environmentObject(locationManager)
    }
  }
}
