import SwiftUI

struct LocationLookupView: View {
  @EnvironmentObject private var locationManager: LocationManager
  let onComplete: (UNNotificationTrigger, CommonFieldsModel) -> Void

  var body: some View {
    Group {
      if locationManager.authorized {
        LocationForm(onComplete: onComplete)
      } else {
        Text(locationManager.authorizationErrorMessage)
      }
    }
    .onAppear(perform: locationManager.requestAuthorization)
  }
}
