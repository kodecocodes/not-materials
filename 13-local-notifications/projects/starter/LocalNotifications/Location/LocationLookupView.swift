import SwiftUI

struct LocationLookupView: View {
  let onComplete: (UNNotificationTrigger, CommonFieldsModel) -> Void

  var body: some View {
    LocationForm(onComplete: onComplete)
  }
}
