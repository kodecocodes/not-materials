import SwiftUI

struct LocationLookupView: View {
  let onComplete: (UNNotificationTrigger, CommonFieldsModel) async throws -> Void

  var body: some View {
    LocationForm(onComplete: onComplete)
  }
}
