import SwiftUI

struct LocationLookupView: View {
  let onComplete: (UNNotificationTrigger, CommonFieldsModel) async throws -> Void
  @EnvironmentObject private var locationManager: LocationManager

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
