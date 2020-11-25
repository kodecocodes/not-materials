import SwiftUI

class CommonFieldsModel: ObservableObject {
  @Published var title = ""
  @Published var badge = ""
  @Published var isRepeating = false
  @Published var hasSound = false

  func reset() {
    title = ""
    badge = ""
    isRepeating = false
    hasSound = false
  }
}
