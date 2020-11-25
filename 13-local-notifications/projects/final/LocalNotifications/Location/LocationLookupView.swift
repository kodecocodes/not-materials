import SwiftUI

struct LocationLookupView: View {
  let onComplete: (UNNotificationTrigger, CommonFieldsModel) -> Void
  @EnvironmentObject private var locationManager: LocationManager

  var body: some View {
    Group {
      if locationManager.authorized {
        LocationForm(onComplete: onComplete)
      } else {
        Text(locationManager.authorizationErrorMessage)
      }
    }
    .onAppear {
      locationManager.requestAuthorization()
    }
  }
}
